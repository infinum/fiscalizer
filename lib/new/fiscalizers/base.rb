module Fiscalizer
  module Fiscalizers
    class Base
      def initialize(fina_cert_path, user_cert_path, password, timeout, object)
        @fina_cert_path = fina_cert_path
        @user_cert_path = user_cert_path
        @password = password
        @timeout = timeout
        @object = object
      end

      attr_reader :fina_cert_path, :user_cert_path, :password, :timeout, :object

      def call
        check_echo
        send_request
      end

      private

      def send_request
        deserialize(request_sender.send(request))
      end

      def request
        serializer.new(object).call
      end

      def deserialize(response)
        deserializer.new(response)
      end

      def request_sender
        @request_sender ||=
          Fiscalizer::RequestSender.new(fina_cert_path, user_cert_path, password, timeout)
      end
    end
  end
end
