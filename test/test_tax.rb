require "test/unit"
require "fiscalizer_ruby"

class TaxTest < Test::Unit::TestCase

	def test_initialization
		# Manual build
		tax = Fiscalizer::Tax.new
		assert tax, "Failed to initialize"
		tax.base = 100
		tax.rate = 25
		tax.name = "My test tax"
		assert_equal 100,			tax.base, "Wrong base assigned"
		assert_equal 25,			tax.rate, "Wrong rate assigned"
		assert_equal "My test tax",	tax.name, "Wrong name assigned"

		tax = nil
		tax = Fiscalizer::Tax.new base: 100, rate: 25, name: "My test tax"
		assert tax, "Failed to initialize"
		assert_equal 100,			tax.base, "Automatically assigned wrong base"
		assert_equal 25,			tax.rate, "Automatically assigned wrong rate"
		assert_equal "My test tax",	tax.name, "Automatically assigned worng name"
	end # test_initialization

	def test_rounding
		# Whole numbers
		tax = Fiscalizer::Tax.new base: 100, rate: 1
		assert_equal 100,	tax.base,  	"Whole number base is wrong"	# 100 -> 100
		assert_equal 1,		tax.rate,  	"Whole number rate is wrong"	# 1 -> 1 -> 0.01
		assert_equal 1,		tax.total, 	"Whole number total is wrong"	# 100 * 0.01 = 1
		assert_equal 101,	tax.summed,	"Whole number summed is wrong"	# 100 + 1 = 101

		# Decimal numbers
		tax = Fiscalizer::Tax.new base: 1.5, rate: 10.5
		assert_equal 1.50,	tax.base,  	"Decimal number base is wrong"		# 1.5 -> 1.5
		assert_equal 10.5,	tax.rate,  	"Decimal number rate is wrong"		# 10.5 -> 10.5 -> 0.105
		assert_equal 0.16,	tax.total, 	"Decimal number total is wrong" 	# 1.5 * 0.105 = 0.1575
		assert_equal 1.66,	tax.summed, "Decimal number summed is wrong"	# 1.5 + 0.16 = 1.66

		# Whole decimal numbers
		tax = Fiscalizer::Tax.new base: 100.0, rate: 1.0
		assert_equal 100.0,	tax.base,  	"Whole decimal number base is wrong"	# 100 -> 100
		assert_equal 1.000,	tax.rate,  	"Whole decimal number rate is wrong"	# 1 -> 1 -> 0.01
		assert_equal 1.000,	tax.total, 	"Whole decimal number total is wrong"	# 100 * 0.01 = 1
		assert_equal 101.0,	tax.summed, "Whole decimal number summed is wrong"	# 100 + 1 = 101

		# Round down
		tax = Fiscalizer::Tax.new base: 13.111992, rate: 10.10499999999
		assert_equal 13.11,	tax.base,  	"Round down number base is wrong"	# 13.111992 -> 13.11
		assert_equal 10.10,	tax.rate,  	"Round down number rate is wrong"	# 10.10499999999 -> 10.10 -> 0.1010
		assert_equal 1.320,	tax.total, 	"Round down number total is wrong"	# 13.11 * 0.1010 = 1.32411
		assert_equal 14.43,	tax.summed, "Round down number summed is wrong"	# 13.11 + 1.32 = 14.43

		# Round up
		tax = Fiscalizer::Tax.new base: 13.2450000001, rate: 25.9989541
		assert_equal 13.25,	tax.base,  	"Round up number base is wrong"		# 13.2450000001 -> 13.25
		assert_equal 26.00,	tax.rate,  	"Round up number rate is wrong"		# 25.9989541 -> 26 -> 0.26
		assert_equal 3.450,	tax.total, 	"Round up number total is wrong"	# 13.25 * 0.26 = 3.445
		assert_equal 16.70,	tax.summed, "Round up number summed is wrong"	# 13.25 + 3.45 = 16.7
	end # test_rounding

	def test_string_conversion
		# Whole numbers
		tax = Fiscalizer::Tax.new base: 100, rate: 1
		assert_equal "100.00",	tax.base_str,  	"Whole number base is wrong"
		assert_equal "1.00",	tax.rate_str,  	"Whole number rate is wrong"
		assert_equal "1.00",	tax.total_str, 	"Whole number total is wrong"
		assert_equal "101.00",	tax.summed_str, "Whole number summed is wrong"

		# Decimal numbers
		tax = Fiscalizer::Tax.new base: 1.5, rate: 10.5
		assert_equal "1.50",	tax.base_str,  	"Decimal number base is wrong"
		assert_equal "10.50",	tax.rate_str,  	"Decimal number rate is wrong"
		assert_equal "0.16",	tax.total_str, 	"Decimal number total is wrong"
		assert_equal "1.66",	tax.summed_str, "Decimal number summed is wrong"

		# Whole decimal numbers
		tax = Fiscalizer::Tax.new base: 100.000, rate: 1.000
		assert_equal "100.00",	tax.base_str,  	"Whole decimal number base is wrong"
		assert_equal "1.00",	tax.rate_str,  	"Whole decimal number rate is wrong"
		assert_equal "1.00",	tax.total_str, 	"Whole decimal number total is wrong"
		assert_equal "101.00",	tax.summed_str, "Whole decimal number summed is wrong"
	end # test_string_conversion

	def test_math

	end # test_math

end