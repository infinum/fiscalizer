# Fiscalizer

## Introduction

Fiscalization is the process of transferring various document types from a business entity to the tax authorities with the goal of reducing tax fraud. In Croatia this process can be executed over the Internet and this gem is intended to automate the process.

## Installation

Add this line to your application's Gemfile:

    gem 'fiscalizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fiscalizer

## Usage

### Setup
To use Fiscalizer initialize a new Fiscalizer object (`fiscalizer = Fiscalizer.new`) with these arguments:

 * `app_cert_path` : Path to your fiscal certificate. (usually "FISCAL_1.p12" or "fiscal1.pfx")
 * `password` : Password that unlocks the certificate

Optional argument is:

 * `timeout` : Specifies the number of seconds to wait for Fiscalization server to respond. (defaults to 3)

Example:

```ruby
fiscalizer = Fiscalizer.new(
  app_cert_path: 'path/to/FISCAL_1.p12',
  password: 'password',
  timeout: 4
)
```
#### Demo environment

If Fiscalizer is used in demo (test) environment, you need to set 2 additional parameters when initializing `Fiscalizer` object:

* `demo` : Specifies that Fiscalizer should send requests to FINA DEMO server. (boolean)
* `ca_cert_path` : Specifies the path to trusted CA certificates. This file should contain both FINA ROOT CA certificate and FINA DEMO CA certificate. (usually called "fina_ca.pem")

Example:

```ruby
fiscalizer = Fiscalizer.new(
  app_cert_path: 'path/to/FISCAL_1.p12',
  password: 'password',
  demo: true,
  ca_cert_path: 'path/to/fina_ca.pem'
)
```

### Fiscalization

Ficalizer class provides 3 public methods:

* `echo(message)`
* `fiscalize_invoice(invoice)`
* `fiscalize_office(office)`

#### Echo

Echo method receives a message, sends it to the Fiscalization server and returns the echo response:

```ruby
response = fiscalizer.echo('Echo message')
response.success? # true
response.echo_response # Echo message
```

#### Invoice

To fiscalize the invoice, you first need to create a `Fiscalizer::Invoice` object and pass it to the `fiscalize_invoice` method.

Before the fiscalization process starts, a `security_code` (ZKI) will be automatically generated and assigned to invoice.
If the fiscalization process is successful, response will contain a `unique_identifier` (JIR). Else, it will contain an array with errors (each error is a hash with `code` and `message`).

`Fiscalizer::Invoice` object can be initialized with the following arguments:

 * `uuid` : Universally Unique Identifier / ID poruke (String, required)
 * `time_sent` : Time the invoice fiscalization request was sent / Datum i vrijeme slanja (DateTime in format dd.mm.yyyyThh:mm:ss, required)
 * `pin` : The fiscal entitie's PIN number / OIB obveznika fiskalizacije (String, required)
 * `in_vat_system` : Specifies if the fical entity is in the VAT system / U sustavu PDV (Boolean, required)
 * `time_issued` : Time the invoice was created / Datum i vrijeme izdavanja (DateTime, required)
 * `consistance_mark` : Character that specifes where the invoice was issued, "P" for _Office space_ or "N" for _Payment machine_ / Oznaka slijednosti (String, required)
 * `issued_number` : Numerical invoice identifier / Brojčana oznaka računa (0-9) (String/Integer, required)
 * `issued_office` : Office space identifier where the invoice was issued / Oznaka poslovnog prostora (String, required)
 * `issued_machine` : Numerical payment machine identifier / Oznaka naplatnog uređaja (String/Integer, required)
 * `tax_vat` : Array containing all VAT taxes / Porez na dodanu vrijednost (Array containing _Fiscalizer::Tax_ objects, optional)
 * `tax_spending` : Array containing all spending taxes / Porez na potrošnju (Array containing _Fiscalizer::Tax_ objects, optional)
 * `tax_other` : Array containing all other taxes / Ostali porezi (Array containing _Fiscalizer::Tax_ objects, optional)
 * `value_tax_liberation` : Amount that will be submitted for tax liberation / Iznos oslobođenja (Float, optional)
 * `value_tax_margin` : Amount that will be subjected to the special tax margin process / Iznos na koji se odnosi poseban postupak oporezivanja marže (Float, optional)
 * `value_non_taxable` : Amount that isn't subject to any taxing / Iznos koji ne podliježe oporezivanju (Float, optional)
 * `fees` : Array containing all fees / Naknade (Array containing _Fiscalizer::Fee_ objects, optional)
 * `summed_total` : Summed total price of the invoice / Ukupan iznos (Float, required)
 * `payment_method` : Specifies the payment method, "G" for cash, "K" for card, "C" for check, "T" for transaction, "O" for other / Način plaćanja (String, required)
 * `operator_pin` : The PIN number of the person issuing the invoice / OIB operatera na naplatnom uređaju (String, required)
 * `subsequent_delivery` : Subsequent delivery mark / Oznaka naknadne dostave računa (Boolean, required)
 * `paragon_label` : Paragon label for the invoice that have to be fiscalized after the office space or payment machine has stopped working / Oznaka paragon računa (String, optional)
 * `specific_purpose` : This is an additional label in case of further expansion of the fiscalization system / Specifična namjena (String, optional)

 After the fiscalization process, response object contains these informations:

 * `raw_response` : XML with the raw response from the Fiscalization server
 * `uuid` : UUID of the response
 * `processed_at` : DateTime when the fiscalization is processed
 * `unique_identifier` : Unique fiscalization identifier of the invoice (JIR) (can be nil if there were errors)
 * `errors?` : Boolean indicating if there were any errors during the process
 * `errors` : Array containing errors if any - Each error is a hash with `code` and `message`

 Fiscalizer invoice object contains these informations after the fiscalization:

 * `security_code` : Security code of the invoice (ZKI)
 * `generated_xml` : XML that was sent to the Fiscalization server

 Example:

```ruby
invoice = YourApp::Invoice.find(...)
fiscalizer_invoice = Fiscalizer::Invoice.new(...) # convert your invoice to fiscalizer invoice
fiscalizer = Fiscalizer.new(
  app_cert_path: 'path/to/FISCAL_1.p12',
  password: 'password'
)

begin
  response = fiscalizer.fiscalize_invoice(fiscalizer_invoice)
  fail 'Fiscalization error' if response.errors? # or do something with the errors
  
  invoice.update(jir: response.unique_identifier)
ensure
  invoice.update(
    fiscalization_response: response.raw_response,
    fiscalization_request: fiscalizer_invoice.generated_xml,
    zki: fiscalizer_invoice.security_code,
    errors: response.errors
  )
end
```

#### Taxes and Fees

When initializing `Fiscalizer::Invoice`, you can set multiple taxes, as indicated above. Those taxes need to be instances of `Fiscalizer::Tax` class.

`Fiscalizer::Tax` object can be initialized with the following arguments:

* `base` : Base amount / Iznos osnovice (Float, required)
* `rate` : Tax rate / Porezna stopa (Float, required)
* `name` : Tax name / Naziv poreza (String, required)

Also, you can set multiple fees for the invoice. Fee need to be instance of the `Fiscalizer::Fee` class.

`Fiscalizer::Fee` object can be initialized with the following arguments:

* `name` : Fee name / Naziv naknade (String, required)
* `value` : Fee amount / Iznos naknade (Float, required)

#### Office

To fiscalize the office space, you first need to create a `Fiscalizer::Office` object and pass it to the `fiscalize_office` method.

`Fiscalizer::Office` object can be initialized with the following arguments:

 * `uuid` : Universally Unique Identifier / ID poruke (String, required)
 * `time_sent` : Time the office space fiscalization request was sent / Datum i vrijeme slanja (DateTime, required)
 * `pin` : The fiscal entitie's PIN number / OIB obveznika fiskalizacije (String, required)
 * `office_label` : Office space identifier / Oznaka poslovnog prostora (String, required)
 * `adress_street_name` : Street name of the office space / Ulica (String, required if `address_other` is not set)
 * `adress_house_num` : House number of the office space / Kućni broj (String, required if `address_other` is not set)
 * `adress_house_num_addendum` : Additional house number of the office space, eg.: "a" or "3/4" / Dodatak kućnom broju (String, optional)
 * `adress_post_num` : Post office number of the office space / Broj pošte (String, required if `address_other` is not set)
 * `adress_settlement` : Settlement name of the office space's location / Naselje (String, optional)
 * `adress_township` : Township name of the office space's location / Naziv općine ili grada (String)
 * `adress_other` : Field to specify non standard office spaces, eg.: "web store" / Ostali tipovi poslovnog prostora (String, optional)
 * `office_time` : Specifies the working hours of the office space / Radno vrijeme (String, required)
 * `take_effect_date` : Date from which the change takes effect / Datum početka primjene (Date, required)
 * `closure_mark` : Mark that indicates the closure of the office space, send "Z" to close / Oznaka zatvaranja (String, optional)
 * `specific_purpose` : Software manufacturer's PIN number / Specifična namjena (String, optional)

 After the fiscalization process, response object contains these informations:

 * `raw_response` : XML with the raw response from the Fiscalization server
 * `uuid` : UUID of the response
 * `processed_at` : DateTime when the fiscalization is processed
 * `errors?` : Boolean indicating if there were any errors during the process
 * `errors` : Array containing errors if any - Each error is a hash with `code` and `message`

 Example:

```ruby
fiscalizer_office = Fiscalizer::Office.new(...)
fiscalizer = Fiscalizer.new(
  app_cert_path: 'path/to/FISCAL_1.p12',
  password: 'password'
)

response = fiscalizer.fiscalize_office(fiscalizer_office)

# do something with the response
```

# Fiscalization specification

The official technical specification for the Fiscalization process can be found
[here](https://www.porezna-uprava.hr/HR_Fiskalizacija/Stranice/Tehni%C4%8Dke-specifikacije.aspx).

# Credits

Fiscalizer is maintained and sponsored by
[Infinum](https://infinum.co/).

<img src="https://infinum.co/infinum.png" width="264">

# License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
