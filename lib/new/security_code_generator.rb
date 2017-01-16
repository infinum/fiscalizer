module Fiscalizer
  class SecurityCodeGenerator
    def initialize(invoice, private_key)
      @invoice = invoice
      @private_key = private_key
    end

    attr_reader :invoice, :private_key

    def call

    end

    private

    def generate_security_code
      # Build data set to generate security code
      unsigned_code = ""
      unsigned_code += invoice.pin
      unsigned_code += invoice.time_issued_str " "
      unsigned_code += invoice.issued_number.to_s
      unsigned_code += invoice.issued_office.to_s
      unsigned_code += invoice.issued_machine.to_s
      unsigned_code += invoice.summed_total_str
      # Sign with my private key
      signed_code = OpenSSL::PKey::RSA.new(key_private).sign(OpenSSL::Digest::SHA1.new, unsigned_code)
      # Create a MD5 digest from it
      md5_digest = Digest::MD5.hexdigest(signed_code)
      invoice.security_code = md5_digest
    end # generate_security_code
  end
end
