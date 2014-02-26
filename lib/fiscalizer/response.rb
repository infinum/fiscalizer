require 'fiscalizer/echo'
require 'fiscalizer/office'
require 'fiscalizer/invoice'

class Fiscalizer
	class Response

		attr_accessor	:type, :errors, :object,
						:uuid, :processed_at, :response,
						:unique_identifier, :tns, :html_response

		def initialize(	type: 0, errors: {}, object: nil, html_response: nil, 
						tns: "http://www.apis-it.hr/fin/2012/types/f73", automatic: true)
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

			if automatic && @object != nil
				@type = 0
				@type = 1 if @object.class == Echo
				@type = 2 if @object.class == Office
				@type = 3 if @object.class == Invoice
			end

			# Automatically fill
			parse_response @html_response.body if @html_response != nil && automatic
		end # initialize

		def generated_xml
			return @object.generated_xml if @object != nil && @object.respond_to?(:generated_xml)
			return nil
		end # generated_xml

		def has_error
			return true if @errors.count > 0
			return false
		end # has_error
		alias_method :errors?, :has_error

		def error_codes
			return errors.keys
		end # error_keys

		def error_messages
			return errors.values
		end # error_messages

		def type_str
			if @type == 0
				return "Error"
			elsif @type == 1
				return "Echo"
			elsif @type == 2
				return "Office"
			elsif @type == 3
				return "Invoice"
			end
			return "Unknown"
		end # type_str

		def echo_succeeded
			return false if @object == nil
			parse_response_echo @html_response.body if @response == nil && @html_response != nil
			return false if @response == nil
			return true if @object.text == @response
			return false
		end
		alias_method :echo?, :echo_succeeded


		private
			def parse_response object
				return nil if object == nil || object.class != String
				if @type == 1
					parse_response_echo object
				elsif @type == 2
					parse_response_office object
				elsif @type == 3
					parse_response_invoice object
				end
				parse_response_errors object
			end # parse_response

			def parse_response_echo object
				@response = Nokogiri::XML(object).root.xpath('//tns:EchoResponse', 'tns' => @tns).first
				@response = @response.text if @response != nil
			end # parse_response_echo

			def parse_response_office object
				@uuid = Nokogiri::XML(object).root.xpath('//tns:IdPoruke', 'tns' => @tns).first
				@processed_at = Nokogiri::XML(object).root.xpath('//tns:DatumVrijeme', 'tns' => @tns).first
				@uuid = @uuid.text if @uuid != nil
				@processed_at = @processed_at.text if @processed_at != nil
			end # parse_response_office

			def parse_response_invoice object
				@uuid = Nokogiri::XML(object).root.xpath('//tns:IdPoruke', 'tns' => @tns).first
				@processed_at = Nokogiri::XML(object).root.xpath('//tns:DatumVrijeme', 'tns' => @tns).first
				@unique_identifier = Nokogiri::XML(object).root.xpath('//tns:Jir', 'tns' => @tns).first
				@uuid = @uuid.text if @uuid != nil
				@processed_at = @processed_at.text if @processed_at != nil
				@unique_identifier = @unique_identifier.text if @unique_identifier != nil
			end # parse_response_office

			def parse_response_errors object
				raw_errors = Nokogiri::XML(object).root.xpath('//tns:Greske', 'tns' => @tns)
				raw_errors.each do |raw_error|
					error_code = raw_error.xpath('//tns:SifraGreske', 'tns' => @tns).first
					error_message = raw_error.xpath('//tns:PorukaGreske', 'tns' => @tns).first
					error_code = error_code.text.strip if error_code != nil
					error_message = error_message.text.strip if error_message != nil
					@errors[error_code] = error_message if error_code != nil
				end
			end

	end # Response
end # Fiscalizer