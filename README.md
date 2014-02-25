# Fiscalizer-Ruby

Fiscalizer-ruby is a ruby gem that allows you to easly create and fiscalize invoices,
office spaces and do echo tests to the fiscalization servers. It is really only envisioned
to be used with the Croatian fiscalization standard.

## Installation

Add this line to your application's Gemfile:

    gem 'fiscalizer-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fiscalizer-ruby

## Usage
### Setup

To use Fiscalizer-ruby in your projects simply call `myFiscalizerObject = Fiscalizer.new`, this will create a new 
Fiscalizer object for you to interact with.

These parameters must be set before you can use any methods:

 * `certificate_p12_path` : Path to your fiscal certificate (usually "FISCAL 1.p12" or "fiscal1.pfx")
 * `password` : Path to your fiscal certificate (usually "FISCAL 1.p12" or "fiscal1.pfx")
 * `key_public_path` : Path to the public key ( "fiskal1.cert" ), will be set automatically from the .p12
 * `key_private_path` : Path to the private key ( "privateKey.key" ), will be set automatically from the .p12
 * `certificate_path` : Path to the certificate ( "certificate.pem" ), will be set automatically from the .p12

Additionaly you can also set these parameters:

 * `url` : Specifies the URL to which the requests will be sent ( defaults to "https://cis.porezna-uprava.hr:8449/FiskalizacijaService")
 * `tns` : Specifies the XML namespaces to use when parsing and encoding objects ( defaults to "http://www.apis-it.hr/fin/2012/types/f73")
 * `schemaLocation` : Specifies the XML schema to use ( defualts to "http://www.apis-it.hr/fin/2012/types/f73 FiskalizacijaSchema.xsd")
 * `certificate_issued_by` : Certificate issuer identifier to be used in the signature ( defaults to "OU=RDC,O=FINA,C=HR")

### Testing / Development

In Test enviroments additionaly to `certificate_p12_path` you have to pass the `.pem` certificate you got to `certificate_path` eg.:

	fiscal = Fiscalizer.new 	certificate_path: "path/to/my/certificate.pem",
								certificate_p12_path: "path/to/my/certificate.p12",
								password: "1234"

But in Production you would use this:

	fiscal = Fiscalizer.new 	certificate_p12_path: "path/to/my/certificate.p12",
								password: "1234"

Remember to configure the test in `test_fiscalizer_ruby.rb`

__IMPORTANT:__ You __have to__ set the `PIN` variable to the same value as in your certificate.

eg.: If i requested my certificat with the PIN (OIB) "123456789", then you have to set the PIN variable to "123456789"


### Fiscalization
To fiscalize a new invoice call the invoice method ( `Fiscalizer.invoice` ) and pass it all the required parameters. 
eg.: `myFicalizerObject.invoice uuid:"myUUID", sent_at: Time.now, ....`

To fiscalize an office space simply call `Fiscalizer.office` and pass it all the required parameters. 
eg.: `myFiscalizerObject.office uuid:"myUUID", sent_at: Time.now, ....`

To make an echo test call `Fiscalizer.echo` and pass it all the required parameters. 
eg.: `myFiscalizerObject.office text:"Hello!?"`

__Note:__ The returned object will contain it's own generated XML request, you can access it by calling `myInvoice.generated_xml`

All these methods return an `Fiscalizer::Response` object.

Methods of the Response object:

 * `object` : Returns the generated object
 * `has_error` : Returns true if there are any errors in the errors hash
 * `errors` : Returns the errors hash ( "error_code" : "error_message" )
 * `error_messages` : Returns ONLY the error messages
 * `error_codes` : Returns ONLY the error codes
 * `echo_succeeded` : Returns true if the echo request returned the same message as the sent one
 * `html_response` : Returns the raw HTML response
 * `generated_xml` : Returns the XML generated for the object
 * `type` : Returns the respones type (0-Error, 1-Invoice, 2-Office, 3-Echo)
 * `type_str` : Returns the respones type as a string ("Error", "Invoice", "Office", "Echo" or "Unkonwn")
 * `tns` : Returns the XML namespace used to pars the responses
 * `uuid` : Returns the UUID from the response
 * `processed_at` : Returns the time when the server processed the request
 * `response` : Returns the echo message from the response
 * `uniqe_identifier` : Returns the uniqe identifier from the response (Croatian: 'JIR')

During creation you can also pass the `automatic:` argument, which is by default true, which sets the response type automatically.


### Objects
__An important note:__ You can build the invoice, office and echo objects your self and pass them to the above
mentioned methods.

 * To create an Invoice: `Fiscalizer::Invoice.new`
 * To create an Office: `Fiscalizer::Office.new`
 * To create an Echo: `Fiscalizer::Echo.new`

And to pass the object do the following:

 * Invoice: `myFiscalizerObject.invoice(invoice: myInvoiceObject)`
 * Office: `myFiscalizerObject.office(office: myOfficeObject)`
 * Echo: `myFiscalizerObject.echo(echo: myEchoObject)`

If you do pass pre-built objects then all other arguments will be ignored except for the `reconnect_attempts` argument.

#### Invoice
Variables:

 * `uuid` = Universal Uniqe Identifier (String)
 * `time_sent` = Time at which the invoice was sent \[Vrijeme slanja\]  (Time)
 * `pin` = Personal Identification Number \[OIB]  (String)
 * `in_vat_system` = Is the person in the VAT system \[U sustavu PDVa\]  (Boolean)
 * `time_issued` = The the Invoice was created \[Vrijeme izdavanja\]  (String)
 * `consistance_mark` = Invoice's consistance mark, "P" for Office or "N" for machine \[Oznaka sljednosti\]  (String)
 * `issued_number` = Number of the Invoice \[Brojčana oznaka računa\]  (String)
 * `issued_office` = Office identifier/Name \[Oznaka poslovnog prostora\]  (String)
 * `issued_machine` = Number of the achine the invoice was issued at \[Oznaka naplatnog uređaja\]  (String)
 * `tax_vat` = Array containing Tax objects \[PDV\]  (Tax)
 * `tax_spending` = Array containing Tax objects \[PNP\]  (Tax)
 * `tax_other` = Array containing Tax objects \[Ostali porezi\]  (Tax)
 * `value_tax_liberation` = \[Iznos oslobođenja\]  (Float)
 * `value_tax_margin` = \[Iznos koji se odnosi na poseban postopak marže\]  (Float)
 * `value_non_taxable` = \[Iznos koji ne podlježe porezu\]  (Float)
 * `fees` = \[Naknade\]  (Fee)
 * `summed_total` = Returns eather the value you passed in or it summes up all the values of the Tax objects \[\]  (Float)
 * `payment_method` = \[Način plaćanja\]  (String)
 * `operator_pin` = \[OBI operatera\]  (String)
 * `security_code` = \[ZKI\]  (String)
 * `subsequent_delivery` = \[Oznaka nadoknadne dostave\]  (String)
 * `paragon_label` = \[Oznaka paragon računa\]  (String)
 * `specific_purpose` = \[Specifična namjena\]  (String)
 * `uniqe_identifier` = \[JIR\]  (String)
 * `generated_xml` = Returns the generated XML while the object was being sent  (String)

Methods:

 * `add_tax_vat base: 0.0, rate: 0.0, name: "", tax: nil` = Adds a Tax object to the tax_vat array, or you can pass a tax object
 * `add_tax_spending base: 0.0, rate: 0.0, name: "", tax: nil` = Adds a Tax object to the tax_spending array
 * `add_tax_other base: 0.0, rate: 0.0, name: "", tax: nil` = Adds a Tax object to the tax_other array, or you can pass a tax object
 * `add_fee name: "", value: 0.0, fee: nil` = Adds a Fee object to the Fees array, or you can pass a fee object
 * `is_valid` = Returns true if all necesary information is present
 * `time_issued_str separator="T"` = Returns the time_issued as a formatted string
 * `time_sent_str separator="T"` = Returns the time_sent as a formatted string
 * `summed_total_str` = Returns the summed_total as a formatted string
 * `value_tax_liberation_str` = Returns the value_tax_liberation as a formatted string
 * `value_tax_margin_str` = Returns the value_tax_margin as a formatted string
 * `value_non_taxable_str` = Returns the value_non_taxable as a formatted string

#### Office
Variables:

 * `uuid` = Universal Uniqe Identifier (String)
 * `time_sent` = \[Vrijeme slanja\]  (Time)
 * `pin` = Personal Identification Number \[OIB\]  (String)
 * `office_label` = \[Oznaka poslovnog prostora\]  (String)
 * `adress_street_name` = \[Ulica\]  (String)
 * `adress_house_num` = \[Kućni broj\]  (String)
 * `adress_house_num_addendum` = \[Dodatak kućno broju\]  (String)
 * `adress_post_num` = \[Broj pošte\]  (String)
 * `adress_settlement` = \[Naselje\]  (String)
 * `adress_township` = \[Općina\]  (String)
 * `adress_other` = \[Ostali tipovi poslovnog prostora\]  (String)
 * `office_time` = \[Radno vrijeme\]  (String)
 * `take_effect_date` = \[Datkum početka primjene\]  (Time)
 * `closure_mark` = \[Oznaka zatvaranja\]  (String)
 * `specific_purpose` = \[Specifična namjena\]  (String)
 * `generated_xml` = Returns the generated XML while the object was being sent  (String)

Methods:

 * `time_sent_str separator="T"` = Returns the time_sent as a formatted string
 * `take_effect_date_str` = Returns the take_effect_date as a formatted string
 * `is_valid` = Returns true if all necesary fields are present

#### Echo
Variables:

 * `text` = Text to be sent in the request (String)
 * `generated_xml` = Returns the generated XML while the object was being sent  (String)

### Usage pattern

Please check the `test` folder to see usage patterns, especially `test/test_fiscalizer_ruby.rb`!!!

#### Invoice initialised
	# Configuration
	key_public  = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/fiskal1.cert"
	key_private = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/privateKey.key"
	certificate = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/democacert.pem"
	url_fiscalization = "https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest"
	certificate_issued_by = "OU=DEMO,O=FINA,C=HR"

	# -- Here Be Dragons --
	fiscal = Fiscalizer.new url: url_fiscalization, 
							key_public_path: key_public,
							key_private_path: key_private,
							certificate: certificate,
							certificate_issued_by: certificate_issued_by
	# Generate taxes
	taxes_vat = []
	taxes_spending = []
	taxes_other = []
	fees = []
	(0..5).each do |i|
		tax = Fiscalizer::Tax.new
		tax.base = rand(10000 * 100).to_f / 100.0
		tax.rate = rand(100 * 100).to_f / 100.0
		taxes_vat << tax
	end
	(0..5).each do |i|
		tax = Fiscalizer::Tax.new
		tax.base = rand(10000 * 100).to_f / 100.0
		tax.rate = rand(100 * 100).to_f / 100.0
		taxes_spending << tax
	end
	(0..5).each do |i|
		tax = Fiscalizer::Tax.new
		tax.base = rand(10000 * 100).to_f / 100.0
		tax.rate = rand(100 * 100).to_f / 100.0
		tax.name = "My Test Tax #{i}"
		taxes_other << tax
	end
	(0..5).each do |i|
		tax = Fiscalizer::Fee.new
		tax.value = rand(10000 * 100).to_f / 100.0
		tax.name = "My Test Fee #{i}"
		fees << tax
	end
	# Generate invoice
	invoice = fiscal.invoice 	uuid: "ca996cc7-fcc3-4c50-961b-40c8b875a5e8",
								time_sent: Time.now,
								pin: "**************",
								in_vat_system: true,
								time_issued: Time.now - 3600,
								consistance_mark: "P",
								issued_number: "1",
								issued_office: "Pm2",
								issued_machine: "3",
								tax_vat: taxes_vat,
								tax_spending: taxes_spending,
								tax_other: taxes_other,
								fees: fees,
								payment_method: "g",
								operator_pin: "**************",
								subsequent_delivery: false,
								value_non_taxable: 200.0
	return invoice.uniqe_identifier if !invoice.error?

#### Invoice created
	# Configuration
	key_public  = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/fiskal1.cert"
	key_private = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/privateKey.key"
	certificate = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/democacert.pem"
	url_fiscalization = "https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest"
	certificate_issued_by = "OU=DEMO,O=FINA,C=HR"

	# -- Here Be Dragons --
	fiscal = Fiscalizer.new url: url_fiscalization, 
							key_public_path: key_public,
							key_private_path: key_private,
							certificate: certificate,
							certificate_issued_by: certificate_issued_by
	# Generate invoice
	myInvoice = Fiscalizer::Invoice 	uuid: "ca996cc7-fcc3-4c50-961b-40c8b875a5e8",
										time_sent: Time.now,
										pin: "**************",
										in_vat_system: true,
										time_issued: Time.now - 3600,
										consistance_mark: "P",
										issued_number: "1",
										issued_office: "Pm2",
										issued_machine: "3",
										payment_method: "g",
										operator_pin: "**************",
										subsequent_delivery: false,
										value_non_taxable: 200.0

	myInvoice.add_tax_vat base: 1000.0, rate: 25.0
	myInvoice.add_tax_spending base: 1000.0, rate: 25.0
	myTax = Fiscalizer::Tax base: 1000.0, rate: 25.0, name: "My Other Tax"
	myInvoice.add_tax_other tax: myTax

	response = fiscal.invoice invoice: myInvoice
	return response.uniqe_identifier if !response.error?

#### Office
	# Configuration
	key_public  = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/fiskal1.cert"
	key_private = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/privateKey.key"
	certificate = "/Users/Stanko/Documents/Ruby-on-Rails/Gems/fiscalizer_ruby/test/assets/democacert.pem"
	url_fiscalization = "https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest"
	certificate_issued_by = "OU=DEMO,O=FINA,C=HR"

	# -- Here Be Dragons --
	fiscal = Fiscalizer.new url: url_fiscalization, 
							key_public_path: key_public,
							key_private_path: key_private,
							certificate: certificate,
							certificate_issued_by: certificate_issued_by
	# Generate invoice
	office = fiscal.office 	uuid: "ca996cc7-fcc3-4c50-961b-40c8b875a5e8",
							time_sent: Time.now,
							pin: "*****************",
							office_label: "Poslovnica1",
							adress_street_name: "Somewhere",
							adress_house_num: "42",
							adress_house_num_addendum: "AD",
							adress_post_num: "10000",
							adress_settlement: "Block 25-C",
							adress_township: "Vogsphere",
							adress_other: nil,
							office_time: "Pon-Pet: 8:00-16:00",
							take_effect_date: Time.now + 3600 * 24 * 7,
							closure_mark: nil,
							specific_purpose: nil
	return "Success!" if !office.error?

#### Echo
    # Configuration
    key_public  = "assets/cert/fiskal1.cert"
    key_private = "assets/cert/privateKey.key"
    certificate = "assets/cert/democacert.pem"
    url_fiscalization = "https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest"
    certificate_issued_by = "OU=DEMO,O=FINA,C=HR"

    # -- Here Be Dragons --
    fiscal = Fiscalizer.new url: url_fiscalization, 
                            key_public_path: key_public,
                            key_private_path: key_private,
                            certificate: certificate,
                            certificate_issued_by: certificate_issued_by
    echo = fiscal.echo text: "This is a simple test..."
    return "Success!" if echo.echo?

## Notes
I don't recommend you to directly use the `Fiscalizer::Communication` class!

Nearly ever method can recive an object instead of parameters, just pass it an argument with the name of the object type.

eg.: `Fiscalizer::Invoice.add_tax_vat tax: myTaxObject`

eg.: `Fiscalizer.invoice invoice: myInvoiceObject`


While sending Invoices and Offices you can specify the number of reconnect attempts by passing `reconnect_attempts` as an argument.

eg.: `Fiscalizer.invoice invoice: myInvoiceObject, reconnect_attempts: 13`