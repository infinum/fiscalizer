class Fiscalizer
  class Fee
    def initialize(name: '', value: 0.0)
      @name = name
      @value = value
    end

    attr_accessor :name, :value

    def value
      @value.to_f.round(2)
    end

    def value_str
      format('%15.2f', value).strip
    end
  end
end
