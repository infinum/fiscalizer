class Fiscalizer
  class RequestSender
    include Constants

    def initialize(app_cert, password, timeout, demo, ca_cert_path)
      @app_cert = app_cert
      @password = password
      @timeout = timeout
      @demo = demo
      @ca_cert_path = ca_cert_path

      prepare_net_http
    end

    attr_reader :app_cert, :password, :timeout, :demo, :ca_cert_path

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
      @uri ||= URI.parse(fiscalization_url)
    end

    def fiscalization_url
      demo ? DEMO_URL : PROD_URL
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
      add_trusted_certificates
    end

    def add_trusted_certificates
      # u produkcijskom okruzenju, trusted CA certifikat se nalazi u
      # istom fileu kao i public i private key
      # taj file ima ekstenziju .p12 (npr. FISKAL_1.p12)
      production_certificates.each do |certificate|
        begin
          http.cert_store.add_cert(certificate)
        rescue OpenSSL::X509::StoreError => err
          # ignore duplicate certs
          # Novi finini certifikati sadze CA koji vec postoje medu default_paths(line 45)
          raise unless err.message == 'cert already in hash table'
        end
      end

      # u testnom okruzenju, treba dodati 2 trusted CA certifikata
      # ta 2 certifikata se nalaze u jednom .pem fileu (npr. fina_ca.pem)
      http.cert_store.add_file(ca_cert_path) unless ca_cert_path.nil? || ca_cert_path == ''
    end

    def production_certificates
      return [] if app_cert.ca_certs.nil?
      app_cert.ca_certs
    end
  end
end
