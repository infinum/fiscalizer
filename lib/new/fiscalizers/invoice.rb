module Fiscalizer
  module Fiscalizers
    class Invoice < Base
      private

      def serializer
        Serializers::Invoice
      end

      def deserializer
        Deserializers::Invoice
      end
    end
  end
end
