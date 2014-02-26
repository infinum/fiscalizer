class Fiscalizer
	class Tax

			attr_accessor :base, :rate, :name

			def initialize base: 0.0, rate: 0.0, name: ""
				@base = base
				@rate = rate
				@name = name
			end # initialize

			# Math
			def base
				return @base.to_f.round(2)
			end # base

			def rate
				return @rate.to_f.round(2)
			end # rate

			def total
				return (base * (rate / 100.0) ).round(2)
			end # total

			def summed
				return (base + total).round(2)
			end # summed

			# Convert to string
			def base_str
				return ("%15.2f" % base).strip
			end # base_str

			def rate_str
				return ("%3.2f" % rate).strip
			end # rate_str

			def total_str
				return ("%15.2f" % total).strip
			end # total_str

			def summed_str
				return ("%15.2f" % summed ).strip
			end # summed_str

	end # Tax
end # Fiscalizer