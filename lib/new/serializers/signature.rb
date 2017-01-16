module Fiscalizer
  module Serializers
    class Signature
      def initialize(xml, reference)
        @xml = xml
        @reference = reference
        @public_key = public_key
        @certificate_issued_by = certificate_issued_by
      end

      attr_reader :xml, :reference, :public_key, :certificate_issued_by

      def call
        xml.Signature('xmlns' => 'http://www.w3.org/2000/09/xmldsig#') do
          add_signed_info
          add_signature_value
          add_key_info
        end
      end

      private

      def add_signed_info
        xml.SignedInfo do
          xml.CanonicalizationMethod('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
          xml.SignatureMethod('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#rsa-sha1')
          xml.Reference('URI' => reference) do
            xml.Transforms do
              xml.Transform('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#enveloped-signature')
              xml.Transform('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
            end
            xml.DigestMethod('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#sha1')
            xml.DigestValue
          end
        end
      end

      def add_signature_value
        xml.SignatureValue
      end

      def add_key_info
        xml.KeyInfo do
          xml.X509Data do
            xml.X509Certificate public_key_string
            xml.X509IssuerSerial do
              xml.X509IssuerName certificate_issued_by
              xml.X509SerialNumber '1053520622'
            end
          end
        end
      end

      def public_key_string
        public_key.to_s
          .gsub('-----BEGIN CERTIFICATE-----', '')
          .gsub('-----END CERTIFICATE-----', '')
          .gsub("\n", '')
      end
    end
  end
end
