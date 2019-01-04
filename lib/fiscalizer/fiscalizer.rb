class Fiscalizer
  def initialize(app_cert_path:, password:, timeout: 3, demo: false, ca_cert_path: nil)
    @app_cert_path = app_cert_path
    @password = password
    @timeout = timeout
    @demo = demo
    @ca_cert_path = ca_cert_path
  end

  attr_reader :app_cert_path, :password, :timeout, :demo, :ca_cert_path

  def echo(message)
    echo = Echo.new(message: message)
    fiscalizer(Fiscalizers::Echo, echo)
  end

  def fiscalize_invoice(invoice)
    fiscalizer(Fiscalizers::Invoice, invoice)
  end

  def fiscalize_office(office)
    fiscalizer(Fiscalizers::Office, office)
  end

  private

  def fiscalizer(fiscalizer_class, object_to_fiscalize)
    fiscalizer_class.new(
      app_cert_path,
      password,
      timeout,
      demo,
      ca_cert_path,
      object_to_fiscalize
    )
  end
end
