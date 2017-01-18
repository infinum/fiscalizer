class Fiscalizer
  class Fee
    attr_accessor :name, :value

    def initialize(name: '', value: 0.0)
      @name = name
      @value = value
    end # initialize

    def value
      @value.to_f.round(2)
    end # value

    def value_str
      format('%15.2f', value).strip
    end # value_str
  end # Fee
end # Fiscalize
