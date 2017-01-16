class Fiscalizer
  def initialize(demo_cert_path, app_cert_path, password, timeout = 3)
    @demo_cert_path = demo_cert_path
    @app_cert_path = app_cert_path
    @password = password
    @timeout = timeout
  end

  attr_reader :demo_cert_path, :app_cert_path, :password, :timeout

  def fiscalize_invoice(invoice)
    fiscalize(Fiscalizers::Invoice, invoice)
  end

  def fiscalize_office(office)
    fiscalize(Fiscalizers::Office, office)
  end

  private

  def fiscalize(fiscalizer_class, object_to_fiscalize)
    fiscalizer_class.new(
      demo_cert_path,
      app_cert_path,
      password,
      timeout,
      object_to_fiscalize
    ).call
  end
end