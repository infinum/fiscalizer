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
To use Fiscalizer in your projects simply call `fiscalizer = Fiscalizer.new` that will create a new fiscalizer object for you to interact with.

Necessary parameters that have to be set before any fiscalization occurs are:

 * `app_cert_path` : Path to your fiscal certificate. (usually "FISCAL_1.p12" or "fiscal1.pfx")
 * `password` : Password that unlocks the certificate

Optional parameter is:

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
* `ca_cert_path` : Specifies the path to your local CA certificates. This file should contain both FINA ROOT CA certificate and FINA DEMO CA certificate. (usually called "fina_ca.pem")

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

Echo method receives a message, sends it to Fiscalization server and returns echo response:

```ruby
response = fiscalizer.echo('Echo message')
response.success? # true
response.echo_response # Echo message
```

#### Invoice

To fiscalize the invoice, you first need to create a `Fiscalizer::Invoice` object and pass it to the `fiscalize_invoice` method.

Before the fiscalization process starts, a security code (ZKI) will be generated and assigned to invoice.
If fiscalization process is successful, response will contain a unique_identifier (JIR). Else, it will contain an array with errors.

Example:

```ruby
```

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

#### Office

To fiscalize the office space, you first need to create a `Fiscalizer::Office` object and pass it to the `fiscalize_office` method.

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
 * __base__ : Osnovica
 * __rate__ : Porezna stopa

# Credits

Fiscalizer is maintained and sponsored by
[Infinum](http://www.infinum.co).

![Infinum](http://www.infinum.co/system/logo.png)

# License

Fiscalizer is Copyright © 2017 Infinum. It is free software, and may be redistributed under the terms specified in the LICENSE file.
