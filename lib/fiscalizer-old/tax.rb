class Fiscalizer
  class Tax
    attr_accessor :base, :rate, :name, :total, :summed

    def initialize(base: 0.0, rate: 0.0, name: '', total: nil, summed: nil)
      @base = base
      @rate = rate
      @name = name
      @total = total
      @summed = summed
    end

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
