class Fiscalizer
	class Communication
		attr_accessor 	:url, :tns, :schemaLocation, 
						:key_public, :key_private, :certificate, 
						:certificate_issued_by

		def initialize(	tns: "http://www.apis-it.hr/fin/2012/types/f73", 
						url: "https://cis.porezna-uprava.hr:8449/FiskalizacijaService",
						schemaLocation: "http://www.apis-it.hr/fin/2012/types/f73 FiskalizacijaSchema.xsd",
						key_public: nil, key_private: nil, certificate: nil,
						certificate_issued_by: "OU=RDC,O=FINA,C=HR" )
			@tns = tns
			@url = url
			@schemaLocation = schemaLocation
			@key_public = key_public
			@key_private = key_private
			@certificate = certificate
			@certificate_issued_by = certificate_issued_by
		end # initialize

		def send object
			# Check input
			raise "Missing keys" if @key_public == nil || @key_private == nil
			raise "Missing certificate" if @certificate == nil
			raise "Can't send nil object" if object == nil

			# Prepare data
			uri  = URI.parse(@url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.cert_store = OpenSSL::X509::Store.new
			http.cert_store.set_default_paths
			http.cert_store.add_cert(@certificate)
			http.verify_mode = OpenSSL::SSL::VERIFY_PEER

			# Encode object
			encoded_object = nil
			if object.class == Echo
				encoded_object = encode_echo object
			elsif object.class == Office
				encoded_object = encode_office object
			elsif object.class == Invoice
				encoded_object = encode_invoice object
			else
				# Something broke so we return false, 
				# this enables us to check sucess in an if statement
				return false
			end

			# Send it
			request 				= Net::HTTP::Post.new(uri.request_uri)
			request.content_type 	= 'application/xml'
			request.body 			= encoded_object
			response 				= http.request(request)
			
			return response
		end # send

		private
			def encode_echo object
				echo_xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
					xml['tns'].EchoRequest(
						'xmlns:tns' => @tns, 
						'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
						'xsi:schemaLocation' => @schemaLocation
					) {
						xml.text object.text
					}
				end
				xml = soap_envelope(echo_xml).to_xml
				object.generated_xml = soap_envelope(echo_xml).to_xml
				return xml
			end # send_echo

			def encode_office object
				office_request_xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
					xml['tns'].PoslovniProstorZahtjev(
						'xmlns:tns' => @tns, 
						'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
						'xsi:schemaLocation' => schemaLocation,
						'Id' => 'PoslovniProstorZahtjev'
					) {
						# Header
						xml['tns'].Zaglavlje {
							xml['tns'].IdPoruke 	object.uuid
							xml['tns'].DatumVrijeme object.time_sent_str
						}
						# Body
						xml['tns'].PoslovniProstor {
							# Important info
							xml['tns'].Oib 				object.pin
							xml['tns'].OznPoslProstora 	object.office_label
							xml['tns'].AdresniPodatak {
								xml['tns'].Adresa {
									xml['tns'].Ulica 			object.adress_street_name
									xml['tns'].KucniBroj 		object.adress_house_num
									xml['tns'].KucniBrojDodatak	object.adress_house_num_addendum
									xml['tns'].BrojPoste 		object.adress_post_num
									xml['tns'].Naselje 			object.adress_settlement
									xml['tns'].Opcina 			object.adress_township
								} if object.adress_other == nil
								xml['tns'].OstaliTipoviPP 		object.adress_other if object.adress_other != nil
							}
							xml['tns'].RadnoVrijeme			object.office_time
							xml['tns'].DatumPocetkaPrimjene	object.take_effect_date_str
							# Optional info
							xml['tns'].OznakaZatvaranja		object.closure_mark if object.closure_mark != nil
							xml['tns'].SpecNamj				object.specific_purpose if object.specific_purpose != nil
						}
						xml.Signature('xmlns' => 'http://www.w3.org/2000/09/xmldsig#') {
							xml.SignedInfo {
								xml.CanonicalizationMethod('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
								xml.SignatureMethod('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#rsa-sha1')
								xml.Reference('URI' => '#PoslovniProstorZahtjev') {
									xml.Transforms {
										xml.Transform('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#enveloped-signature')
										xml.Transform('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
									}
									xml.DigestMethod('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#sha1')
									xml.DigestValue
								}
							}
							xml.SignatureValue
							xml.KeyInfo {
								xml.X509Data {
									xml.X509Certificate key_public.to_s.gsub('-----BEGIN CERTIFICATE-----','').gsub('-----END CERTIFICATE-----','').gsub("\n",'')
									xml.X509IssuerSerial {
										xml.X509IssuerName @certificate_issued_by
										xml.X509SerialNumber "1053520622" # Explane
									}
								}
							}
						}
					}
				end

				body = soap_envelope(office_request_xml)
				unsigned_document = Xmldsig_fiscalizer::SignedDocument.new(body.doc.root.to_xml)
				signed_xml = unsigned_document.sign(@key_private)
				signed_xml.sub! '<?xml version="1.0"?>', ''
				signed_xml = signed_xml.gsub /^$\n/, ''

				object.generated_xml = signed_xml

				return signed_xml
			end # send_office

			def encode_invoice object
				generate_security_code object
				invoice_request_xml = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
					xml['tns'].RacunZahtjev(
						'xmlns:tns' => @tns, 
						'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
						'xsi:schemaLocation' => schemaLocation,
						'Id' => 'RacunZahtjev'
					) {
						# Header
						xml['tns'].Zaglavlje {
							xml['tns'].IdPoruke 	object.uuid
							xml['tns'].DatumVrijeme object.time_sent_str
						}
						# Body
						xml['tns'].Racun {
							# Important info
							xml['tns'].Oib 			object.pin
							xml['tns'].USustPdv 	object.in_vat_system
							xml['tns'].DatVrijeme 	object.time_issued_str
							xml['tns'].OznSlijed 	object.consistance_mark
							# Invoice issued numbers
							xml['tns'].BrRac {
								xml['tns'].BrOznRac object.issued_number.to_s
								xml['tns'].OznPosPr object.issued_office.to_s
								xml['tns'].OznNapUr object.issued_machine.to_s
							}
							# Optional info
							# Tax VAT
							xml['tns'].Pdv {
								object.tax_vat.each do |tax|
									xml['tns'].Porez {
										xml['tns'].Stopa 	tax.rate_str
										xml['tns'].Osnovica tax.base_str
										xml['tns'].Iznos 	tax.total_str
									}
								end
							} if object.tax_vat != nil && object.tax_vat.size != 0
							# Tax Spending
							xml['tns'].Pnp {
								object.tax_spending.each do |tax|
									xml['tns'].Porez {
										xml['tns'].Stopa 	tax.rate_str
										xml['tns'].Osnovica tax.base_str
										xml['tns'].Iznos 	tax.total_str
									}
								end
							} if object.tax_spending != nil && object.tax_spending.size != 0
							# Tax Other
							xml['tns'].OstaliPor {
								object.tax_other.each do |tax|
									xml['tns'].Porez {
										xml['tns'].Naziv 	tax.name
										xml['tns'].Stopa 	tax.rate_str
										xml['tns'].Osnovica tax.base_str
										xml['tns'].Iznos 	tax.total_str
									}
								end
							} if object.tax_other != nil && object.tax_other.size != 0
							# Tax info
							xml['tns'].IznosOslobPdv 	object.value_tax_liberation_str	if object.value_tax_liberation_str != nil
							xml['tns'].IznosMarza 		object.value_tax_margin_str		if object.value_tax_margin_str != nil
							xml['tns'].IznosNePodlOpor 	object.value_non_taxable_str 	if object.value_non_taxable_str != nil
							# Fees
							xml['tns'].Naknade {
								object.tax_other.each do |tax|
									xml['tns'].Naknada {
										xml['tns'].NazivN 	tax.name
										xml['tns'].IznosN 	tax.rate_str
									}
								end
							} if object.fees != nil && object.fees.size != 0
							# Important info
							xml['tns'].IznosUkupno 	object.summed_total_str
							xml['tns'].NacinPlac 	object.payment_method
							xml['tns'].OibOper 		object.operator_pin
							xml['tns'].ZastKod 		object.security_code
							xml['tns'].NakDost 		object.subsequent_delivery
							# Optional info
							xml['tns'].ParagonBrRac 	object.paragon_label	if object.paragon_label != nil
							xml['tns'].SpecNamj 		object.specific_purpose	if object.specific_purpose != nil
						}
						xml.Signature('xmlns' => 'http://www.w3.org/2000/09/xmldsig#') {
							xml.SignedInfo {
								xml.CanonicalizationMethod('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
								xml.SignatureMethod('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#rsa-sha1')
								xml.Reference('URI' => '#RacunZahtjev') {
									xml.Transforms {
										xml.Transform('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#enveloped-signature')
										xml.Transform('Algorithm' => 'http://www.w3.org/2001/10/xml-exc-c14n#')
									}
									xml.DigestMethod('Algorithm' => 'http://www.w3.org/2000/09/xmldsig#sha1')
									xml.DigestValue
								}
							}
							xml.SignatureValue
							xml.KeyInfo {
								xml.X509Data {
									xml.X509Certificate key_public.to_s.gsub('-----BEGIN CERTIFICATE-----','').gsub('-----END CERTIFICATE-----','').gsub("\n",'')
									xml.X509IssuerSerial {
										xml.X509IssuerName @certificate_issued_by
										xml.X509SerialNumber "1053520622" # Explane
									}
								}
							}
						}
					}
				end

				body = soap_envelope(invoice_request_xml)
				unsigned_document = Xmldsig_fiscalizer::SignedDocument.new(body.doc.root.to_xml)
				signed_xml = unsigned_document.sign(@key_private)
				signed_xml.sub! '<?xml version="1.0"?>', ''
				signed_xml = signed_xml.gsub /^$\n/, ''

				object.generated_xml = signed_xml

				return signed_xml
			end # encode_invoice

			def soap_envelope req_xml
				return Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
					xml['soapenv'].Envelope('xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/') {
						xml['soapenv'].Body {
							xml << req_xml.doc.root.to_xml
						}
					}
				end
			end # soap_envelope

			def generate_security_code invoice
				# Build data set to generate security code
				unsigned_code = ""
				unsigned_code += invoice.pin
				unsigned_code += invoice.time_sent_str " "
				unsigned_code += invoice.issued_number.to_s
				unsigned_code += invoice.issued_office.to_s
				unsigned_code += invoice.issued_machine.to_s
				unsigned_code += invoice.summed_total_str
				# Sign with my private key
				signed_code = OpenSSL::PKey::RSA.new(key_private).sign(OpenSSL::Digest::SHA1.new, unsigned_code)
				# Create a MD5 digest from it
				md5_digest = Digest::MD5.hexdigest(signed_code)
				invoice.security_code = md5_digest
				return md5_digest
			end # generate_security_code

	end # Communication
end # Fiscalizer