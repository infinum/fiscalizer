class Fiscalizer
  def initialize(app_cert_path:, password:, timeout: 3, demo: false, demo_cert_path: nil)
    @app_cert_path = app_cert_path
    @password = password
    @timeout = timeout
    @demo = demo
    @demo_cert_path = demo_cert_path
  end

  attr_reader :app_cert_path, :password, :timeout, :demo, :demo_cert_path

  def fiscalize_invoice(invoice)
    # TODO: reconnect attempts?
    fiscalize(Fiscalizers::Invoice, invoice)
  end

  def fiscalize_office(office)
    fiscalize(Fiscalizers::Office, office)
  end

  private

  def fiscalize(fiscalizer_class, object_to_fiscalize)
    fiscalizer_class.new(
      app_cert_path,
      password,
      timeout,
      demo,
      demo_cert_path,
      object_to_fiscalize
    ).call
  end
end
