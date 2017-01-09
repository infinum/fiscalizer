require 'fiscalizer/tax'
require 'fiscalizer/fee'

class Fiscalizer
  class Invoice
    attr_accessor :uuid, :time_sent, :pin,
                  :in_vat_system, :time_issued, :consistance_mark,
                  :issued_number, :issued_office, :issued_machine,
                  :tax_vat, :tax_spending, :tax_other,
                  :value_tax_liberation, :value_tax_margin, :value_non_taxable,
                  :fees, :summed_total, :payment_method,
                  :operator_pin, :security_code, :subsequent_delivery,
                  :paragon_label, :specific_purpose, :unique_identifier,
                  :automatic, :generated_xml

    def initialize(uuid: nil, time_sent: nil, pin: nil,
                   in_vat_system: nil, time_issued: nil, consistance_mark: nil,
                   issued_number: nil, issued_office: nil, issued_machine: nil,
                   tax_vat: [], tax_spending: [], tax_other: [],
                   value_tax_liberation: nil, value_tax_margin: nil, value_non_taxable: nil,
                   fees: [], summed_total: nil, payment_method: nil,
                   operator_pin: nil, security_code: nil, subsequent_delivery: nil,
                   paragon_label: nil, specific_purpose: nil, unique_identifier: nil,
                   automatic: true)
      @uuid = uuid
      @time_sent = time_sent
      @pin = pin
      @in_vat_system = in_vat_system
      @time_issued = time_issued
      @consistance_mark = consistance_mark
      @issued_number = issued_number
      @issued_office = issued_office
      @issued_machine = issued_machine
      @tax_vat = tax_vat
      @tax_spending = tax_spending
      @tax_other = tax_other
      @value_tax_liberation = value_tax_liberation
      @value_tax_margin = value_tax_margin
      @value_non_taxable = value_non_taxable
      @fees = fees
      @summed_total = summed_total
      @payment_method = payment_method
      @operator_pin = operator_pin
      @security_code = security_code
      @subsequent_delivery = subsequent_delivery
      @paragon_label = paragon_label
      @specific_purpose = specific_purpose
      @unique_identifier = unique_identifier
      @automatic = automatic

      autocomplete_data_set if @automatic
    end # initialize

    # Add taxes
    def add_tax_vat(tax = nil, base: 0.0, rate: 0.0, name: '')
      tax = Fiscalizer::Tax.new base: base, rate: rate, name: name if tax.nil?
      @tax_vat = [] if @tax_vat.class != Array
      @tax_vat << tax
    end # add_tax_vat

    def add_tax_spending(tax = nil, base: 0.0, rate: 0.0, name: '')
      tax = Fiscalizer::Tax.new base: base, rate: rate, name: name if tax.nil?
      @tax_spending = [] if @tax_spending.class != Array
      @tax_spending << tax
    end # add_tax_spending

    def add_tax_other(tax = nil, base: 0.0, rate: 0.0, name: '')
      tax = Fiscalizer::Tax.new base: base, rate: rate, name: name if tax.nil?
      @tax_other = [] if @tax_other.class != Array
      @tax_other << tax
    end # add_tax_spending

    # Add fee
    def add_fee(fee = nil, name: '', value: 0.0)
      fee = Fiscalizer::Fee.new(name: base, value: rate) if fee.nil?
      @fee << fee
    end # add_fee

    # Check if all necessary values are present
    def is_valid
      # Check values
      return false unless uuid && time_sent && pin && in_vat_system && time_issued &&
                          consistance_mark && issued_number && issued_office &&
                          issued_machine && summed_total && payment_method &&
                          operator_pin && security_code && subsequent_delivery

      # Check taxes
      tax_vat.each do |tax|
        return false if tax.name.nil? || tax.name.class != String
        return false if tax.base.nil?
        return false if tax.rate.nil?
      end # tax_vat.each

      tax_spending.each do |tax|
        return false if tax.name.nil? || tax.name.class != String
        return false if tax.base.nil?
        return false if tax.rate.nil?
      end # tax_spending.each

      tax_other.each do |tax|
        return false if tax.name.nil? || tax.name.class != String
        return false if tax.base.nil?
        return false if tax.rate.nil?
      end # tax_other.each

      # Check fees
      fees.each do |fee|
        return false if fee.name.nil?  || fee.name.class  != String
        return false if fee.value.nil? || fee.value.class != Float
      end # fees.each

      true
    end # is_valid
    alias valid? is_valid
    alias valdate is_valid

    # Getters
    def time_issued_str(separator = 'T')
      @time_issued.strftime('%d.%m.%Y') + separator + @time_issued.strftime('%H:%M:%S')
    end # time_issued_str

    def time_sent_str(separator = 'T')
      @time_sent.strftime('%d.%m.%Y') + separator + @time_sent.strftime('%H:%M:%S')
    end # time_sent_str

    def summed_total
      return @summed_total unless @summed_total.nil?
      total = 0.0
      tax_vat.each { |tax| total += tax.summed }
      tax_spending.each { |tax| total += tax.summed }
      tax_other.each { |tax| total += tax.summed }
      total.round(2)
    end # summed_total

    def summed_total_str
      ('%15.2f' % summed_total).strip
    end # summed_total_str

    def payment_method
      return @payment_method[0].upcase if %w(G K C T O).include?(@payment_method[0].upcase)
      raise 'Invalid payment method type!'
    end # payment_method

    def consistance_mark
      @consistance_mark.upcase
    end # consistance_mark

    def value_tax_liberation_str
      return nil if @value_tax_liberation.nil?
      ('%15.2f' % @value_tax_liberation.round(2)).strip
    end # value_tax_liberation_str

    def value_tax_margin_str
      return nil if @value_tax_margin.nil?
      ('%15.2f' % @value_tax_margin.round(2)).strip
    end # value_tax_margin_str

    def value_non_taxable_str
      return nil if @value_non_taxable.nil?
      ('%15.2f' % @value_non_taxable.round(2)).strip
    end # value_non_taxable_str

    # Helpers
    def autocomplete_data_set
    end # autocomplete_data_set
  end # Invoice
end # Fiscalizer
