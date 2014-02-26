fiscal = Fiscalizer.new certificate_p12_path: "/path/to/FISKAL 1.p12",
						password: "12345678"

# Generate office
office = Fiscalizer::Office.new
office.uuid = 
office.time_sent = Time.now
office.pin = "00123456789"
office.office_label = "Poslovnica1"
office.adress_street_name = "Somewhere"
office.adress_house_num = "42"
office.adress_house_num_addendum = "AD"
office.adress_post_num = "10000"
office.adress_settlement = "Block 25-C"
office.adress_township = "Vogsphere"
office.adress_other = nil
office.office_time = "Pon-Pet: 8:00-16:00"
office.take_effect_date = Time.now + 3600 * 24 * 7
office.closure_mark = nil
office.specific_purpose = nil

# Generate office
office_response = fiscal.fiscalize_office office

puts "The server returned the following UUID: " + office_response.uuid if !office_response.errors?
puts "Office space fiscalization was successful!" if !office_response.errors?