class Fiscalizer
  module Deserializers
    class Base
      include Constants

      def initialize(raw_response, object)
        @raw_response = raw_response
        @object = object
      end

      attr_reader :raw_response, :object

      def uuid
        element_value(root, 'IdPoruke')
      end

      def processed_at
        element_value(root, 'DatumVrijeme')
      end

      def errors?
        error_nodes.any?
      end

      def errors
        @errors ||= begin
          [].tap do |array|
            error_nodes.each do |error_node|
              code = element_value(error_node, 'SifraGreske')
              message = element_value(error_node, 'PorukaGreske')
              next if code.nil?

              array << { code: code, message: message }
            end
          end
        end
      end

      private

      def element_value(root_node, element)
        element = find(root_node, element).first
        return if element.nil?

        element.text
      end

      def find(root_node, element)
        root_node.xpath("//tns:#{element}", 'tns' => TNS)
      end

      def root
        Nokogiri::XML(raw_response.body).root
      end

      def error_nodes
        @error_nodes ||= find(root, 'Greska')
      end
    end
  end
end
