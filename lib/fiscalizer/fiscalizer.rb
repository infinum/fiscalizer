class Fiscalizer
  def initialize(app_cert_path:, password:, timeout: 3, demo: false, ca_cert_path: nil)
    @app_cert_path = app_cert_path
    @password = password
    @timeout = timeout
    @demo = demo
    @ca_cert_path = ca_cert_path
  end

  attr_reader :app_cert_path, :password, :timeout, :demo, :ca_cert_path, :security_code

  def echo(message)
    echo = Echo.new(message: message)
    fiscalize(Fiscalizers::Echo, echo).call
  end

  def fiscalize_invoice(invoice)
    fiscalizer = fiscalize(Fiscalizers::Invoice, invoice)
    response = fiscalizer.call
    @security_code = fiscalizer.security_code
    response
  end

  def fiscalize_office(office)
    fiscalize(Fiscalizers::Office, office).call
  end

  private

  def fiscalize(fiscalizer_class, object_to_fiscalize)
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
