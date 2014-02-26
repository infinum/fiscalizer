# Fiscalizer

## Introduction

Fiscalization is the process of transfering various document types from a business entity to the tax authorities with the goal of reducing tax fraud. In Croatia this process can be executed over the Internet, this gem is intended to automate this process.

## Documentation

Every folder has it's own README file which explanes in detail the files in it.

Examples are located in the `example` folder. Basic setup and fiscalization are demonstrated here.

Tests are located in the `test` folder. Test setup is explaned there.

All classes, in their separate files, are located in the `fiscalizer` folder.

## Instalation

Add this line to your application's Gemfile:

    gem 'fiscalizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fiscalizer

## Usage
### Setup
To use Fiscalizer in your projects simply call `fiscalizer = Fiscalizer.new`, this will create a new fiscalizer object for you to interact with.

Necessary parameters, that have to be set before any fiscalization occures are:

 * `certificate_p12_path` : Path to your fiscal certificate (usually "FISCAL 1.p12" or "fiscal1.pfx")
 * `password` : Password that unlocks the certificate

Alternatively you can set these three parameters:

 * `key_public_path` : Path to the public key ( "fiskal1.cert" )
 * `key_private_path` : Path to the private key ( "privateKey.key" )
 * `certificate_path` : Path to the certificate ( "certificate.pem" )

__NOTE:__ Thise parameters will override the parameters extracted from the P12 certificate!

Parameters that can also be set:

 * `url` : Specifies the URL to which the requests will be sent ( defaults to "https://cis.porezna-uprava.hr:8449/FiskalizacijaService")
 * `tns` : Specifies the XML namespaces to use when parsing and encoding objects ( defaults to "http://www.apis-it.hr/fin/2012/types/f73")
 * `schemaLocation` : Specifies the XML schema to be used for XML parsing ( defualts to "http://www.apis-it.hr/fin/2012/types/f73 FiskalizacijaSchema.xsd")
 * `certificate_issued_by` : Certificate issuer identifier to be used in the signature ( defaults to "OU=RDC,O=FINA,C=HR")

### Fiscalization

This gem offers two types of fiscalization, _Office space_ and _Invoice_ fiscalization. _Echo_ requests are also possible.

All these methods return an `Fiscalizer::Response` object, which is explaned below.

#### Invoices

To fiscalize an invoice call `fiscalizer.fiscalize_invoice` and pass it an `Fiscalizer::Invoice` object.

Alternatively it is possible to pass all the arguments needed to build an invoice, this will build an invoice
and fiscalize it automatically.

Arguments that can be passed to `fiscalizer.fiscalize_invoice`:

 * `uuid` : Universally Unique Identifier (String)
 * `time_sent` : Time the invoice fiscalization request was sent (Time)
 * `pin` : The fiscal entitie's PIN number (String)
 * `in_vat_system` : Specifies if the fical entity is in the VAT system (Boolean)
 * `time_issued` : Time the invoice was created (Time)
 * `consistance_mark` : Character that specifes where the invoice was issued, "P" for _Office space_ or "N" for _Payment machine_ (String)
 * `issued_number` : Nummerical invoice identifier (String ot Integer)
 * `issued_office` : Office space identifier where the invoice was issued (String)
 * `issued_machine` : Numerical payment machine identifier (String or Integer)
 * `tax_vat` : Array containing all VAT taxes (Array containing _Fiscalizer::Tax_ objects)
 * `tax_spending` : Array containing all spending taxes (Array containing _Fiscalizer::Tax_ objects)
 * `tax_other` : Array containing all other taxes (Array containing _Fiscalizer::Tax_ objects)
 * `value_tax_liberation` : Ammount that will be submitted for tax liberation (Float)
 * `value_tax_margin` : Ammount that will be subjected to the special tax margin process (Float)
 * `value_non_taxable` : Ammount that isn't subject to any taxing (Float)
 * `fees` : Array containing all fees (Array containing _Fiscalizer::Fee_ objects)
 * `summed_total` : Summed total price of the invoice (Float)
 * `payment_method` : Specifies the payment method, "G" for cash, "K" for card, "C" for check, "T" for transaction, "O" for other (String)
 * `operator_pin` : The PIN number of the person issuing the invoice (String)
 * `security_code` : Security code of the invoice (String)
 * `subsequent_delivery` : Subsequent delivery mark (Boolean)
 * `paragon_label` : Paragon label for invoices that have to be fiscalized after the office space or payment machine has been removed from the fiscalization system (String)
 * `specific_purpose` : This is an additional label in case of further expansion of the fiscalization system (String)
 * `unique_identifier` : Unique identifier of the invoice (String)
 * `reconnect_attempts` : Specifies how many times to try establishing a connection, defaults to 3 (Integer)

__Note:__ `summed_total` will return the sum of all taxed values from `tax_vat`, `tax_spending`, `tax_other`

#### Office spaces

To fiscalize an office space call `fiscalizer.fiscalize_office` and pass it an `Fiscalizer::Office` object.

Arguments that can be passed to `fiscalizer.fiscalize_office`:

 * `uuid` : Universally Unique Identifier (String)
 * `time_sent` : Time the office space fiscalization request was sent (Time)
 * `pin` : The fiscal entitie's PIN number (String)
 * `office_label` : Office space identifier string (String)
 * `adress_street_name` : Name of the street the where the office space is located (String)
 * `adress_house_num` : House number of the office space (String)
 * `adress_house_num_addendum` : Additional house number of the office space, eg.: "a" or "3/4" (String)
 * `adress_post_num` : Post office number of the office space (String)
 * `adress_settlement` : Settlement name of the office space's location (String)
 * `adress_township` : Township name of the office space's location (String)
 * `adress_other` : Field to specify non standart office spaces, eg.: "web store" (String)
 * `office_time` : Specifies the working hours of the office space, anything is valid (String)
 * `take_effect_date` : Date from which the change takes effect (Time)
 * `closure_mark` : Mark that indicates the cloasure of the office space, send "Z" to close (String)
 * `specific_purpose` : Software manufacturer's PIN number (String)
 * `reconnect_attempts` : Specifies how many times to try establishing a connection, defaults to 3 (Integer)

#### Echo requests

Even though echo requests are not particularly usefull for fiscalization they are described in the API and
therefore they are also implemented.

To make an echo request call `fiscalizer.echo` and eather pass it na `Fiscalizer::Echo` object or `text: "Your echo text"`
as an argument.

#### Responses

Response objects are perhaps the most important objects in this Gem.
They contain pre-parsed information that was returned from the fiscalization servers.

Methods:
 * `type` : Type of the response, 0-Error, 1-Echo, 2-Office, 3-Invoice (Integer)
 * `errors` : Hash containg all errors returned from the server, the key is the error code, and the value is the error explanation (Hash)
 * `object` : Holds the object that generated the response (Echo, Invoice, Office)
 * `uuid` : UUID returned by the server (String)
 * `processed_at` : Time the request was processed (Time)
 * `response` : Text returned in an Echo message (String)
 * `unique_identifier` : Unique invoice identifier (String)
 * `tns` : TNS used to parse the XML responses (String)
 * `html_response` : Raw HTML response (HTTP::Response)
 * `generated_xml` : XML generated for the reqest to which this response belongs (String)
 * `has_error` : Returns true if there are any arrors (Boolean), alia method `errors?`
 * `error_codes` : Returns all error codes in an array (Array containing String)
 * `error_messages` : Returns all error messages in an array (Array containing String)
 * `type_str` : Returnes the response type as a string (String)
 * `echo_succeeded` : Returns true if echo message sent and returned are the same (Boolean)

# Notes

The public and private keys, and signing certificate are automatically extracted from a P12 certificate.
But the same is not true for a PFX certificate! PFX certificates don't contain a signing certificate and
therefore one has to be passed as an argument (`certificate_path`) additionaly to the PFX certificate (`certificate_p12_path`)

Direct usage of the `Fiscalizer::Communication` class is not advised!

# Translations

 * __uuid__ : UUID
 * __time_sent__ : Datum i vrijeme slanja
 * __pin__ : OIB
 * __office_label__ : Oznaka poslovnog prostora
 * __adress_street_name__ : Ime ulice
 * __adress_house_num__ : Kućni broj
 * __adress_house_num_addendum__ : Dodatak kućnom broju
 * __adress_post_num__ : Broj pošte
 * __adress_settlement__ : Nasenje
 * __adress_township__ : Općina
 * __adress_other__ : Ostali tipovo poslovnog porstora
 * __office_time__ : Radno vrijeme
 * __take_effect_date__ : Datum početka primjene
 * __closure_mark__ : Oznaka zatvaranja
 * __specific_purpose__ : Specifična namjena
 * __in_vat_system__ : U sustavu PDVa
 * __time_issued__ : Datum i vrijeme izdavanja
 * __consistance_mark__ : Oznaka slijednosti
 * __issued_number__ : Brojčana oznaka računa
 * __issued_office__ : Oznaka poslovnog prostora
 * __issued_machine__ : Oznaka naplatnog uređaja
 * __tax_vat__ : PDV
 * __tax_spending__ : PNP 
 * __tax_other__ : Ostali porezi
 * __value_tax_liberation__ : Iznos oslobođenja
 * __value_tax_margin__ : Iznos koji se odnosi na poseban postupak oporezivanja marže
 * __value_non_taxable__ : Iznos koji ne podlježe oporezivanju
 * __fees__ : Naknade
 * __summed_total__ : Ukupan iznos
 * __payment_method__ : Način plaćanja
 * __operator_pin__ : OIB operatera
 * __security_code__ : Zaštitni kod izdavatelja (ZKI)
 * __subsequent_delivery__ : Oznaka nadoknadne dostave
 * __paragon_label__ : Oznaka paragon računa
 * __specific_purpose__ : Specifična namjena
 * __unique_identifier__ : Jedinstveni identifikator računa (JIR)

# Credits

Phrasing is maintained and sponsored by
[Infinum](http://www.infinum.co).

![Infinum](http://www.infinum.co/system/logo.png)

# License

Phrasing is Copyright © 2014 Infinum. It is free software, and may be redistributed under the terms specified in the LICENSE file.