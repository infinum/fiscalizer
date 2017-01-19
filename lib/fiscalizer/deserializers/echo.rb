class Fiscalizer
  module Deserializers
    class Echo < Base
      def echo_response
        element_value(root, 'EchoResponse')
      end

      def success?
        echo_response == object.message
      end
    end
  end
end
