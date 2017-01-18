class Fiscalizer
  module Serializers
    class Office < Base
      private

      def message_id
        'PoslovniProstorZahtjev'
      end

      def raw_xml
        @raw_xml ||= begin
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml['tns'].PoslovniProstorZahtjev(root_hash) do
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
        xml['tns'].PoslovniProstor do
          add_general_info(xml)
          add_address_info(xml)
          add_time_info(xml)
          add_closure_mark(xml)
          add_specific_purpose(xml)
        end
      end

      def add_general_info(xml)
        xml['tns'].Oib object.pin
        xml['tns'].OznPoslProstora object.office_label
      end

      def add_address_info(xml)
        xml['tns'].AdresniPodatak do
          add_address(xml)
          add_other_address(xml)
        end
      end

      def add_address(xml)
        return if object.adress_other

        xml['tns'].Adresa do
          xml['tns'].Ulica object.adress_street_name
          xml['tns'].KucniBroj object.adress_house_num
          xml['tns'].KucniBrojDodatak	object.adress_house_num_addendum
          xml['tns'].BrojPoste object.adress_post_num
          xml['tns'].Naselje object.adress_settlement
          xml['tns'].Opcina object.adress_township
        end
      end

      def add_other_address(xml)
        return if object.adress_other.nil?
        xml['tns'].OstaliTipoviP object.adress_other
      end

      def add_time_info(xml)
        xml['tns'].RadnoVrijeme object.office_time
        xml['tns'].DatumPocetkaPrimjene	object.take_effect_date_str
      end

      def add_closure_mark(xml)
        return if object.closure_mark.nil?
        xml['tns'].OznakaZatvaranja object.closure_mark
      end

      def add_specific_purpose(xml)
        return if object.specific_purpose.nil?
        xml['tns'].SpecNamj object.specific_purpose
      end
    end
  end
end
