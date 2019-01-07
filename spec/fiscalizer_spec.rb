describe Fiscalizer do
  let(:ca_cert_path) { 'spec/support/test.pem' }
  let(:app_cert_path) { 'spec/support/test.p12' }
  let(:password) { 'infinum1' }
  let(:pin) { 'test_pin' }
  let(:timeout) { 3 }
  let(:demo_url) { Fiscalizer::Constants.const_get(:DEMO_URL) }

  let(:fiscalizer) do
    Fiscalizer.new(
      app_cert_path: app_cert_path,
      password: password,
      demo: true,
      ca_cert_path: ca_cert_path,
      timeout: timeout
    )
  end

  context 'echo' do
    it 'returns status 200' do
      stub_request(:any, demo_url).
        to_return(
          status: 200,
          body: File.read(get_response_file('echo')),
          headers: { content_type: 'text/xml' }
        )

      response = fiscalizer.echo('test')

      expect(response.success?).to be(true)
      expect(response.echo_response).to eq('test')
    end
  end

  context 'invoice' do
    let(:invoice) do
      Fiscalizer::Invoice.new(
        uuid: SecureRandom.uuid,
        time_sent: Time.now,
        pin: pin,
        in_vat_system: true,
        time_issued: Time.now - 3600,
        consistance_mark: 'P',
        issued_number: '1',
        issued_office: 'Pm2',
        issued_machine: '3',
        summed_total: 250.0,
        payment_method: 'K',
        operator_pin: '12345678900',
        subsequent_delivery: false
      )
    end

    before do
      tax = Fiscalizer::Tax.new(base: 100.0, rate: 25.0, name: 'PDV')
      invoice.tax_vat << tax
    end

    context 'valid' do
      it 'should return JIR' do
        stub_request(:any, demo_url).
          to_return(
            status: 200,
            body: File.read(get_response_file('invoices/valid')),
            headers: { content_type: 'text/xml' }
          )

        response = fiscalizer.fiscalize_invoice(invoice)

        expect(response.errors?).to be(false)
        expect(invoice.security_code).not_to be(nil)
        expect(response.unique_identifier).not_to be(nil)
        expect(response.uuid).not_to be(nil)
        expect(response.processed_at).not_to be(nil)
        expect(invoice.security_code).not_to be(nil)
      end
    end

    context 'invalid' do
      let(:pin) { '00000000000' }

      it 'should return error' do
        stub_request(:any, demo_url).
          to_return(
            status: 200,
            body: File.read(get_response_file('invoices/invalid')),
            headers: { content_type: 'text/xml' }
          )

        response = fiscalizer.fiscalize_invoice(invoice)

        expect(response.errors?).to be(true)
        expect(invoice.security_code).not_to be(nil)
        expect(response.unique_identifier).to be(nil)
        expect(response.errors.first[:code]).to eq('s005')
        expect(invoice.security_code).not_to be(nil)
      end
    end

    context 'timeout error' do
      let(:timeout) { 0 }

      it 'should raise read timeout error' do
        stub_request(:any, demo_url).to_raise(Net::ReadTimeout)

        expect { fiscalizer.fiscalize_invoice(invoice) }.to raise_error(Net::ReadTimeout)
        expect(invoice.security_code).not_to be(nil)
      end
    end
  end

  context 'office' do
    let(:office) do
      Fiscalizer::Office.new(
        uuid: SecureRandom.uuid,
        time_sent: Time.now,
        pin: pin,
        office_label: 'Poslovnica1',
        adress_street_name: 'Adresa',
        adress_house_num: '42',
        adress_house_num_addendum: 'AD',
        adress_post_num: '10000',
        adress_settlement: 'Block 25-C',
        adress_township: 'Zagreb',
        office_time: 'Pon-Pet: 8:00-16:00',
        take_effect_date: Time.now + 3600 * 24 * 7
      )
    end

    context 'valid' do
      it 'should fiscalize office' do
        stub_request(:any, demo_url).
          to_return(
            status: 200,
            body: File.read(get_response_file('offices/valid')),
            headers: { content_type: 'text/xml' }
          )

        response = fiscalizer.fiscalize_office(office)
        expect(response.errors?).to be(false)
        expect(response.uuid).not_to be(nil)
        expect(response.processed_at).not_to be(nil)
      end
    end

    context 'invalid' do
      let(:pin) { '00000000000' }

      it 'should return error' do
        stub_request(:any, demo_url).
          to_return(
            status: 200,
            body: File.read(get_response_file('offices/invalid')),
            headers: { content_type: 'text/xml' }
          )

        response = fiscalizer.fiscalize_office(office)
        expect(response.errors?).to be(true)
        expect(response.errors.first[:code]).to eq('s005')
      end
    end
  end
end
