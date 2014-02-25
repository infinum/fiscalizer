require "test/unit"
require "fiscalizer_ruby"

class CommunicationTest < Test::Unit::TestCase

	def test_initialization
		# Manual build
		comm = Fiscalizer::Communication.new
		assert comm, "Failed to initialize"

		# Default value
		assert_equal "http://www.apis-it.hr/fin/2012/types/f73", comm.tns, "Tns was not assigned by default"
		assert_equal "http://www.apis-it.hr/fin/2012/types/f73 FiskalizacijaSchema.xsd", comm.schemaLocation, "Schema Location was not assigned by default"

		# Manual assignment
		comm.tns = "test.tns.hr"
		comm.schemaLocation = "test.tns.hr/Schema.xml"
		assert_equal "test.tns.hr", 			comm.tns, 				"Tns was not assigned"
		assert_equal "test.tns.hr/Schema.xml", 	comm.schemaLocation, 	"Schema Location was not assigned"

		# Automatic assignment
		comm = nil
		comm = Fiscalizer::Communication.new tns: "test.tns.hr", schemaLocation: "test.tns.hr/Schema.xml"
		assert_equal "test.tns.hr", 			comm.tns, 				"Tns was not assigned"
		assert_equal "test.tns.hr/Schema.xml", 	comm.schemaLocation, 	"Schema Location was not assigned"
	end # test_initialization

end