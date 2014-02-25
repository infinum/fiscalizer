require "test/unit"
require "fiscalizer_ruby"

class EchoTest < Test::Unit::TestCase

	def test_initialization
		# Manual build
		echo = Fiscalizer::Echo.new
		echo.text = "This is a test of text assignment"
		# Test
		assert_equal "This is a test of text assignment", echo.text, "Text was not assigned"

		# Automatic test
		echo = nil
		echo = Fiscalizer::Echo.new text: "This is a test of text assignment"
		# Test
		assert_equal "This is a test of text assignment", echo.text, "Text was not automatically assigned"
	end # test_initialization

end # EchoTest