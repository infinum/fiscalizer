module Fiscalizer
  class SecurityCodeGenerator
    def initialize(invoice, private_key)
      @invoice = invoice
      @private_key = private_key
    end

    attr_reader :invoice, :private_key

    def call
      invoice.security_code = md5_digest
    end

    private

    def md5_digest
      Digest::MD5.hexdigest(signed_code)
    end

    def signed_code
      OpenSSL::PKey::RSA.new(private_key).sign(OpenSSL::Digest::SHA1.new, unsigned_code)
    end

    def unsigned_code
      invoice.pin + invoice.time_issued_str('') + invoice.issued_number.to_s +
        invoice.issued_office.to_s + invoice.issued_machine.to_s + invoice.summed_total_str
    end
  end
end
