fiscal = Fiscalizer.new certificate_p12_path: "/path/to/FISKAL 1.p12",
						password: "12345678"

# Generate Invoice
invoice = Fiscalizer::Invoice.new
invoice.uuid = UUID
invoice.time_sent = Time.now
invoice.pin = "00123456789"
invoice.in_vat_system = true
invoice.time_issued = Time.now - 3600
invoice.consistance_mark = "P"
invoice.issued_number = "1"
invoice.issued_office = "Pm2"
invoice.issued_machine = "3"
invoice.payment_method = "g"
invoice.operator_pin = "12345678900"
invoice.subsequent_delivery = false
invoice.value_non_taxable = 200.0

# Generate taxes
(0..5).each do |i|
	tax = Fiscalizer::Tax.new
	tax.base = rand(10000 * 100).to_f / 100.0
	tax.rate = rand(100 * 100).to_f / 100.0
	invoice.add_tax_vat tax
end
(0..5).each do |i|
	tax = Fiscalizer::Tax.new
	tax.base = rand(10000 * 100).to_f / 100.0
	tax.rate = rand(100 * 100).to_f / 100.0
	invoice.add_tax_other base: base, rate: rate, name: "Other tax #{i}" 
end
(0..5).each do |i|
	fee = Fiscalizer::Fee.new
	fee.value = rand(10000 * 100).to_f / 100.0
	fee.name = "My Test Fee #{i}"
	invoice.add_fee fee
end
(0..5).each do |i|
	fee = Fiscalizer::Fee.new
	fee.value = rand(10000 * 100).to_f / 100.0
	fee.name = "My Test Fee #{i}"
	invoice.add_fee value: value, name: name
end
# Generate invoice
invoice_response = fiscal.fiscalize_invoice invoice

puts "The server returned the following JIR: " + invoice_response.unique_identifier if !invoice_response.errors?