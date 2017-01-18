class Fiscalizer
  module Fiscalizers
    class Echo < Base
      def serializer
        Serializers::Echo
      end

      def deserializer
        Deserializers::Echo
      end
    end
  end
end
