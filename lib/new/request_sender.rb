module Fiscalizer
  class RequestSender
    def initialize(fina_cert_path, user_cert_path, password, timeout)
      @fina_cert_path = fina_cert_path
      @user_cert_path = user_cert_path
      @password = password
      @timeout = timeout

      prepare_net_http
    end

    def send(message)
      request.content_type = 'application/xml'
      request.body = message
      http.request(request)
    end

    private

    def http
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end

    def uri
      @uri ||= URI.parse(FISCALIZATION_URL)
    end

    def request
      @request ||= Net::HTTP::Post.new(uri.request_uri)
    end

    def prepare_net_http
      http.read_timeout = timeout
      http.use_ssl = true
      http.cert_store = OpenSSL::X509::Store.new
      http.cert_store.set_default_paths
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      add_fina_certificates
    end

    def add_fina_certificates
      certificates.each do |certificate|
        http.cert_store.add_cert(certificate)
      end
    end

    def certificates
    end
  end
end
