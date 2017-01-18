class Fiscalizer
  module Fiscalizers
    class Invoice < Base
      def call
        generate_security_code
        send_request
      end

      private

      def generate_security_code
        SecurityCodeGenerator.new(object, app_private_key).call
      end

      def serializer
        Serializers::Invoice
      end

      def deserializer
        Deserializers::Invoice
      end
    end
  end
end
