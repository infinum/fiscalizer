class Fiscalizer
  class Invoice
    # rubocop:disable Metrics/ParameterLists, Metrics/AbcSize, Metrics/MethodLength
    def initialize(uuid:, time_sent:, pin:, in_vat_system:, time_issued:, consistance_mark:,
                   issued_number:, issued_office:, issued_machine:, summed_total:,
                   payment_method:, operator_pin:, subsequent_delivery:,
                   tax_vat: [], tax_spending: [], tax_other: [],
                   value_tax_liberation: nil, value_tax_margin: nil, value_non_taxable: nil,
                   fees: [], paragon_label: nil, specific_purpose: nil)

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
      @subsequent_delivery = subsequent_delivery
      @paragon_label = paragon_label
      @specific_purpose = specific_purpose
    end

    attr_reader :uuid, :time_sent, :pin,
                :in_vat_system, :time_issued, :consistance_mark,
                :issued_number, :issued_office, :issued_machine,
                :tax_vat, :tax_spending, :tax_other,
                :value_tax_liberation, :value_tax_margin, :value_non_taxable,
                :fees, :summed_total, :payment_method,
                :operator_pin, :subsequent_delivery,
                :paragon_label, :specific_purpose

    attr_accessor :security_code, :generated_xml

    def time_issued_str(separator = 'T')
      time_issued.strftime("%d.%m.%Y#{separator}%H:%M:%S")
    end

    def time_sent_str(separator = 'T')
      time_sent.strftime("%d.%m.%Y#{separator}%H:%M:%S")
    end

    def summed_total_str
      format_decimal(summed_total)
    end

    def value_tax_liberation_str
      return if value_tax_liberation.nil?
      format_decimal(value_tax_liberation.round(2))
    end

    def value_tax_margin_str
      return if value_tax_margin.nil?
      format_decimal(value_tax_margin.round(2))
    end

    def value_non_taxable_str
      return if value_non_taxable.nil?
      format_decimal(value_non_taxable.round(2))
    end

    private

    def format_decimal(value)
      format('%15.2f', value).strip
    end
  end
end
