class Fiscalizer
  class Tax
    def initialize(base:, rate:, name:)
      @base = base
      @rate = rate
      @name = name
    end

    attr_accessor :base, :rate, :name, :total, :summed

    def total
      @total || (base.to_f * (rate.to_f / 100.0)).round(2)
    end

    def summed
      @summed || (base.to_f + total.to_f).round(2)
    end

    def base_str
      format('%15.2f', base).strip
    end

    def rate_str
      format('%3.2f', rate).strip
    end

    def total_str
      format('%15.2f', total).strip
    end

    def summed_str
      format('%15.2f', summed).strip
    end
  end
end
