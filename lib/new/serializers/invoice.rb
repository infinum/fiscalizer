module Fiscalizer
  module Serializers
    class Invoice
      private

      def message_id
        'RacunZahtjev'
      end

      def raw_xml
        @raw_xml ||= begin
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml['tns'].RacunZahtjev(root_hash) do
              add_header(xml)
              add_body(xml)
              add_signature(xml)
            end
          end
        end
      end

      def add_header(xml)
        xml['tns'].Zaglavlje do
          xml['tns'].IdPoruke object.uuid
          xml['tns'].DatumVrijeme object.time_sent_str
        end
      end

      def add_body(xml)
        xml['tns'].Racun do
          add_general_invoice_info(xml)
          add_invoice_number_info(xml)
          add_invoice_tax_info
          add_invoice_fee_info(xml)
          add_invoice_summary(xml)
        end
      end

      def add_general_invoice_info(xml)
        xml['tns'].Oib object.pin
        xml['tns'].USustPdv object.in_vat_system
        xml['tns'].DatVrijeme object.time_issued_str
        xml['tns'].OznSlijed object.consistance_mark
      end

      def add_invoice_number_info(xml)
        xml['tns'].BrRac do
          xml['tns'].BrOznRac object.issued_number.to_s
          xml['tns'].OznPosPr object.issued_office.to_s
          xml['tns'].OznNapUr object.issued_machine.to_s
        end
      end

      def add_invoice_tax_info(xml)
        add_vat_tax(xml)
        add_spending_tax(xml)
        add_other_taxes(xml)
        add_general_tax_info(xml)
      end

      def add_vat_tax(xml)
        return if object.tax_vat.empty?

        xml['tns'].Pdv do
          object.tax_vat.each do |tax|
            xml['tns'].Porez do
              xml['tns'].Stopa tax.rate_str
              xml['tns'].Osnovica tax.base_str
              xml['tns'].Iznos tax.total_str
            end
          end
        end
      end

      def add_spending_tax(xml)
        return if object.tax_spending.empty?

        xml['tns'].Pnp do
          object.tax_spending.each do |tax|
            xml['tns'].Porez do
              xml['tns'].Stopa tax.rate_str
              xml['tns'].Osnovica tax.base_str
              xml['tns'].Iznos tax.total_str
            end
          end
        end
      end

      def add_other_taxes(xml)
        return if object.tax_other.empty?

        xml['tns'].OstaliPor do
          object.tax_other.each do |tax|
            xml['tns'].Porez do
              xml['tns'].Naziv tax.name
              xml['tns'].Stopa tax.rate_str
              xml['tns'].Osnovica tax.base_str
              xml['tns'].Iznos tax.total_str
            end
          end
        end
      end

      def add_general_tax_info(xml)
        xml['tns'].IznosOslobPdv object.value_tax_liberation_str if object.value_tax_liberation_str.present?
        xml['tns'].IznosMarza object.value_tax_margin_str if object.value_tax_margin_str.present?
        xml['tns'].IznosNePodlOpor object.value_non_taxable_str if object.value_non_taxable_str.present?
      end

      def add_invoice_fee_info(xml)
        return if object.fees.empty?

        xml['tns'].Naknade do
          object.fees.each do |tax|
            xml['tns'].Naknada do
              xml['tns'].NazivN tax.name
              xml['tns'].IznosN tax.value
            end
          end
        end
      end

      def add_invoice_summary(xml)
        xml['tns'].IznosUkupno object.summed_total_str
        xml['tns'].NacinPlac object.payment_method
        xml['tns'].OibOper object.operator_pin
        xml['tns'].ZastKod object.security_code
        xml['tns'].NakDost object.subsequent_delivery

        xml['tns'].ParagonBrRac object.paragon_label if object.paragon_label.present?
        xml['tns'].SpecNamj object.specific_purpose if object.specific_purpose.present?
      end
    end
  end
end
