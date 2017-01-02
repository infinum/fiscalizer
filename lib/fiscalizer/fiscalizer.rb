require 'fiscalizer/communication'
require 'fiscalizer/echo'
require 'fiscalizer/office'
require 'fiscalizer/invoice'
require 'fiscalizer/response'

class Fiscalizer
  # Accessible attributes
  attr_accessor :url, :key_public_path, :key_private_path, :certificate_path,
                :key_private, :key_public, :certificate,
                :tns, :schemaLocation, :certificate_issued_by,
                :timeout

  # Public methods
  def initialize(url: 'https://cis.porezna-uprava.hr:8449/FiskalizacijaService',
                 key_public_path: nil, key_private_path: nil, certificate_path: nil,
                 tns: 'http://www.apis-it.hr/fin/2012/types/f73',
                 schemaLocation: 'http://www.apis-it.hr/fin/2012/types/f73 FiskalizacijaSchema.xsd',
                 certificate_issued_by: 'OU=RDC,O=FINA,C=HR', certificate_p12_path: nil,
                 password: nil, timeout: 3)
    @url = url
    @key_public_path  = key_public_path
    @key_private_path = key_private_path
    @certificate_path = certificate_path
    @certificate_p12_path = certificate_p12_path
    @tns = tns
    @schemaLocation = schemaLocation
    @timeout = timeout

    # Import certificates
    export_keys password

    if @key_public_path.present? && File.exist?(@key_public_path)
      @key_public  = OpenSSL::X509::Certificate.new(File.read(@key_public_path))
    end

    if @key_private_path.present? && File.exist?(@key_private_path)
      @key_private = OpenSSL::PKey::RSA.new(File.read(@key_private_path))
    end

    if @certificate_path.present? && File.exist?(@certificate_path)
      @certificate = OpenSSL::X509::Certificate.new(File.read(@certificate_path))
    end
  end # new

  def echo(echo = nil, text: 'Hello World!')
    # Build echo request
    echo = Fiscalizer::Echo.new(text: text) if echo.nil?
    # Send it
    comm = Fiscalizer::Communication.new(url: @url, tns: @tns, schemaLocation: @schemaLocation,
                                         key_public: @key_public, key_private: @key_private,
                                         certificate: @certificate,
                                         certificate_issued_by: @certificate_issued_by,
                                         timeout: @timeout)
    raw_response = comm.send echo
    Fiscalizer::Response.new(object: echo, html_response: raw_response, tns: @tns)
  end # echo

  def fiscalize_office(office = nil, uuid: nil, time_sent: nil, pin: nil,
                       office_label: nil, adress_street_name: nil, adress_house_num: nil,
                       adress_house_num_addendum: nil, adress_post_num: nil, adress_settlement: nil,
                       adress_township: nil, adress_other: nil, office_time: nil,
                       take_effect_date: nil, closure_mark: nil, specific_purpose: nil,
                       reconnect_attempts: 3)
    # Test connection
    response_alive = echo(text: 'Is the server alive?')
    recconect_attempted = 1
    reconnect_attempts = 0 if reconnect_attempts < 0
    while recconect_attempted < reconnect_attempts && !response_alive.echo?
      response_alive = echo(text: 'Is the server alive?')
      recconect_attempted += 1
    end
    unless response_alive.echo?
      response_alive.type = 0
      response_alive.errors['f100'] = 'Failed to connect to server'
      return response_alive
    end
    # Build office
    office =
      Fiscalizer::Office.new(uuid: uuid, time_sent: time_sent, pin: pin,
                             office_label: office_label, adress_street_name: adress_street_name,
                             adress_house_num: adress_house_num,
                             adress_house_num_addendum: adress_house_num_addendum,
                             adress_post_num: adress_post_num, adress_settlement: adress_settlement,
                             adress_township: adress_township, adress_other: adress_other,
                             office_time: office_time, take_effect_date: take_effect_date,
                             closure_mark: closure_mark,
                             specific_purpose: specific_purpose) if office.nil?
    # Send it
    comm = Fiscalizer::Communication.new(url: @url, tns: @tns, schemaLocation: @schemaLocation,
                                         key_public: @key_public, key_private: @key_private,
                                         certificate: @certificate,
                                         certificate_issued_by: @certificate_issued_by,
                                         timeout: @timeout)
    raw_response = comm.send(office)
    Fiscalizer::Response.new object: office, html_response: raw_response, tns: @tns
  end # fiscalize_office
  alias office fiscalize_office
  alias fiscalize_office_space fiscalize_office

  def fiscalize_invoice(invoice = nil, uuid: nil, time_sent: nil, pin: nil,
                        in_vat_system: nil, time_issued: nil, consistance_mark: nil,
                        issued_number: nil, issued_office: nil, issued_machine: nil,
                        tax_vat: [], tax_spending: [], tax_other: [],
                        value_tax_liberation: nil, value_tax_margin: nil, value_non_taxable: nil,
                        fees: [], summed_total: nil, payment_method: nil,
                        operator_pin: nil, security_code: nil, subsequent_delivery: nil,
                        paragon_label: nil, specific_purpose: nil, unique_identifier: nil,
                        automatic: true, reconnect_attempts: 3)
    # Test connection
    response_alive = echo text: 'Is the server alive'
    recconect_attempted = 1
    reconnect_attempts = 0 if reconnect_attempts < 0
    while recconect_attempted < reconnect_attempts && !response_alive.echo?
      response_alive = echo text: 'Is the server alive'
      recconect_attempted += 1
    end
    unless response_alive.echo?
      response_alive.type = 0
      response_alive.errors['f100'] = 'Failed to connect to server'
      return response_alive
    end
    # Build invoice
    invoice =
      Fiscalizer::Invoice.new(uuid: uuid, time_sent: time_sent, pin: pin,
                              in_vat_system: in_vat_system, time_issued: time_issued,
                              consistance_mark: consistance_mark, issued_number: issued_number,
                              issued_office: issued_office, issued_machine: issued_machine,
                              tax_vat: tax_vat, tax_spending: tax_spending, tax_other: tax_other,
                              value_tax_liberation: value_tax_liberation,
                              value_tax_margin: value_tax_margin,
                              value_non_taxable: value_non_taxable,
                              fees: fees, summed_total: summed_total,
                              payment_method: payment_method,
                              operator_pin: operator_pin, security_code: security_code,
                              subsequent_delivery: subsequent_delivery,
                              paragon_label: paragon_label, specific_purpose: specific_purpose,
                              unique_identifier: unique_identifier,
                              automatic: automatic) if invoice.nil?
    # Send it
    comm =
      Fiscalizer::Communication.new(url: @url, tns: @tns, schemaLocation: @schemaLocation,
                                    key_public: @key_public, key_private: @key_private,
                                    certificate: @certificate,
                                    certificate_issued_by: @certificate_issued_by,
                                    timeout: @timeout)
    raw_response = comm.send invoice
    Fiscalizer::Response.new object: invoice, html_response: raw_response, tns: @tns
  end # fiscalize_invoice
  alias invoice fiscalize_invoice

  def certificate_p12_path=(path)
    @certificate_p12_path = path
    export_keys
  end # certificate_p12_path

  private

  def export_keys(password)
    if @certificate_p12_path.present? && File.exist?(@certificate_p12_path) && password.present?
      extracted = OpenSSL::PKCS12.new(File.read(@certificate_p12_path), password)
      @key_public  = OpenSSL::X509::Certificate.new(extracted.certificate)
      @key_private = OpenSSL::PKey::RSA.new(extracted.key)
      if extracted.ca_certs.present? && !extracted.ca_certs.empty?
        @certificate = OpenSSL::X509::Certificate.new(extracted.ca_certs.first.to_s)
      end
    end
  end # export_keys
end # FiscalizerRuby
