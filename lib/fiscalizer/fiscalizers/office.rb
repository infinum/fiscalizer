class Fiscalizer
  module Fiscalizers
    class Office < Base
      private

      def serializer
        Serializers::Office
      end

      def deserializer
        Deserializers::Office
      end
    end
  end
end
