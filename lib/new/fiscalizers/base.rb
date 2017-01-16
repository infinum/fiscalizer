module Fiscalizer
  module Fiscalizers
    class Base
      def initialize(demo_cert_path, app_cert_path, password, timeout, object)
        @demo_cert_path = demo_cert_path
        @app_cert_path = app_cert_path
        @password = password
        @timeout = timeout
        @object = object
      end

      attr_reader :demo_cert_path, :app_cert_path, :password, :timeout, :object

      def call
        check_echo
        send_request
      end

      private

      def send_request
        response = request_sender.send(request_message)
        deserialize(response)
      end

      def request_message
        serializer.new(object, app_private_key, app_public_key).call
      end

      def deserialize(response)
        deserializer.new(response)
      end

      def request_sender
        @request_sender ||=
          Fiscalizer::RequestSender.new(demo_cert_path, extracted_app_cert, password, timeout)
      end

      def app_public_key
        @app_public_key ||= OpenSSL::X509::Certificate.new(extracted_app_cert.certificate)
      end

      def app_private_key
        @app_private_key ||= OpenSSL::PKey::RSA.new(extracted_app_cert.key)
      end

      def extracted_app_cert
        @extracted_app_cert ||= OpenSSL::PKCS12.new(File.read(app_cert_path), password)
      end
    end
  end
end
