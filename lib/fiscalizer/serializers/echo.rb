class Fiscalizer
  module Serializers
    class Echo < Base
      private

      def message_id
        'EchoRequest'
      end

      def raw_xml
        @raw_xml ||= begin
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml['tns'].EchoRequest(root_hash) do
              xml.text object.message
            end
          end
        end
      end
    end
  end
end
