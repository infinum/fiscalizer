require 'fiscalizer/echo'
require 'fiscalizer/office'
require 'fiscalizer/invoice'

class Fiscalizer
  class Response
    attr_accessor :type, :errors, :object,
                  :uuid, :processed_at, :response,
                  :unique_identifier, :tns, :html_response

    def initialize(type: 0, errors: {}, object: nil, html_response: nil,
                   tns: 'http://www.apis-it.hr/fin/2012/types/f73', automatic: true)
      # Save
      @type = type
      @errors = errors
      @object = object
      @uuid = uuid
      @processed_at = processed_at
      @response = response
      @unique_identifier = unique_identifier
      @tns = tns
      @html_response = html_response

      if automatic && !@object.nil?
        @type = 0
        @type = 1 if @object.class == Echo
        @type = 2 if @object.class == Office
        @type = 3 if @object.class == Invoice
      end

      # Automatically fill
      parse_response(@html_response.body) if !@html_response.nil? && automatic
    end # initialize

    def generated_xml
      return @object.generated_xml if !@object.nil? && @object.respond_to?(:generated_xml)
      nil
    end # generated_xml

    def has_error
      return true if @errors.count > 0
      false
    end # has_error
    alias errors? has_error
    alias error? has_error

    def error_codes
      errors.keys
    end # error_keys

    def error_messages
      errors.values
    end # error_messages

    def type_str
      case @type
      when 0 then return 'Error'
      when 1 then return 'Echo'
      when 2 then return 'Office'
      when 3 then return 'Invoice'
      end
      'Unknown'
    end # type_str

    def echo_succeeded
      return false if @object.nil?
      parse_response_echo(@html_response.body) if @response.nil? && !@html_response.nil?
      return false if @response.nil?
      return true if @object.text == @response
      false
    end
    alias echo? echo_succeeded

    private

    def parse_response(object)
      return nil if object.class != String
      case @type
      when 1 then parse_response_echo(object)
      when 2 then parse_response_office(object)
      when 3 then parse_response_invoice(object)
      else parse_response_errors(object)
      end
    end # parse_response

    def parse_response_echo(object)
      @response = Nokogiri::XML(object).root.xpath('//tns:EchoResponse', 'tns' => @tns).first
      @response = @response.text unless @response.nil?
    end # parse_response_echo

    def parse_response_office(object)
      @uuid = Nokogiri::XML(object).root.xpath('//tns:IdPoruke', 'tns' => @tns).first
      @processed_at = Nokogiri::XML(object).root.xpath('//tns:DatumVrijeme', 'tns' => @tns).first
      @uuid = @uuid.text unless @uuid.nil?
      @processed_at = @processed_at.text unless @processed_at.nil?
    end # parse_response_office

    def parse_response_invoice(object)
      @uuid = Nokogiri::XML(object).root.xpath('//tns:IdPoruke', 'tns' => @tns).first
      @processed_at = Nokogiri::XML(object).root.xpath('//tns:DatumVrijeme', 'tns' => @tns).first
      @unique_identifier = Nokogiri::XML(object).root.xpath('//tns:Jir', 'tns' => @tns).first
      @uuid = @uuid.text unless @uuid.nil?
      @processed_at = @processed_at.text unless @processed_at.nil?
      @unique_identifier = @unique_identifier.text unless @unique_identifier.nil?
    end # parse_response_office

    def parse_response_errors(object)
      raw_errors = Nokogiri::XML(object).root.xpath('//tns:Greska', 'tns' => @tns)
      raw_errors.each do |raw_error|
        error_code = raw_error.xpath('//tns:SifraGreske', 'tns' => @tns).first
        error_message = raw_error.xpath('//tns:PorukaGreske', 'tns' => @tns).first
        error_code = error_code.text.strip unless error_code.nil?
        error_message = error_message.text.strip unless error_message.nil?
        @errors[error_code] = error_message unless error_code.nil?
      end
    end
  end # Response
end # Fiscalizer
