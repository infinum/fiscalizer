fiscal = Fiscalizer.new certificate_p12_path: "/path/to/FISKAL 1.p12",
						password: "12345678"

# Generate office
office_response = fiscal.office 	uuid: "ca996cc7-fcc3-4c50-961b-40c8b875a5e8",
									time_sent: Time.now,
									pin: "00123456789",
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

puts "The server returned the following UUID: " + office_response.uuid if !office_response.errors?
puts "Office space fiscalization was successful!" if !office_response.errors?