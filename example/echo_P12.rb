fiscal = Fiscalizer.new certificate_p12_path: "/path/to/FISKAL 1.p12",
						password: "12345678"
echo_response = fiscal.echo text: "It's mearly a flesh wound!"

if echo_response.errors?
	puts "There were some nasty errors!"
	echo_response.errors.each do |error_code, error_message|
		puts "	" + error_code + " : " + error_message
	end
end

puts "The server returned: " + echo_response.response
puts "The echo request was successful! Great success!" if echo_response.echo?