fiscal = Fiscalizer.new certificate_p12_path: "/path/to/FISKAL 1.p12",
						password: "12345678"
# Generate taxes
taxes_vat = []
taxes_spending = []
taxes_other = []
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
# Generate invoice
invoice_response = fiscal.invoice 	uuid: UUID,
									time_sent: Time.now,
									pin: PIN,
									in_vat_system: true,
									time_issued: Time.now - 3600,
									consistance_mark: "P",
									issued_number: "1",
									issued_office: "Pm2",
									issued_machine: "3",
									tax_vat: taxes_vat,
									tax_spending: taxes_spending,
									tax_other: taxes_other,
									payment_method: "g",
									operator_pin: PIN_OPERATOR,
									subsequent_delivery: false,
									value_non_taxable: 200.0

puts "The server returned the following JIR: " + invoice_response.unique_identifier if !invoice_response.errors?