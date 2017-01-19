class Fiscalizer
  module Serializers
    class Invoice < Base
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
          add_invoice_tax_info(xml)
          add_invoice_fee_info(xml)
          add_invoice_summary(xml)
          add_paragon_label(xml)
          add_specific_purpose(xml)
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
        Serializers::Tax.new(xml, object).call
      end

      def add_invoice_fee_info(xml)
        return if object.fees.empty?

        xml['tns'].Naknade do
          object.fees.each do |fee|
            xml['tns'].Naknada do
              xml['tns'].NazivN fee.name
              xml['tns'].IznosN fee.value
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
      end

      def add_paragon_label(xml)
        return if object.paragon_label.nil?
        xml['tns'].ParagonBrRac object.paragon_label
      end

      def add_specific_purpose(xml)
        return if object.specific_purpose.nil?
        xml['tns'].SpecNamj object.specific_purpose
      end
    end
  end
end
