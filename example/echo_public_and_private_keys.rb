fiscal = Fiscalizer.new url: "https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest",  
						key_public_path: "/path/to/fiskal1.cert",
						key_private_path: "/path/to/privateKey.key",
						certificate_path: "/path/to/democacert.pem",
						certificate_issued_by: "OU=DEMO,O=FINA,C=HR"
echo_response = fiscal.echo text: "It's mearly a flesh wound!"

if echo_response.errors?
	puts "There were some nasty errors!"
	echo_response.errors.each do |error_code, error_message|
		puts "	" + error_code + " : " + error_message
	end
end

puts "The server returned: " + echo_response.response
puts "The echo request was successful! Great success!" if echo_response.echo?