# Test

## Setup

It is important that in test enviroments both a P12 certificate (`certificate_p12_path`) and a signing certificate are passed to the Fiscalizer object (`certificate_path`). This is important because the test P12 certificates (suffixed with `.pfx`) don't contain signing certificates in them!

Don't forget to configutre all static variables in `test_fiscalizer.rb`

`EXPORTED_KEYS` specifies weather to initialize a Fiscalizer object with a P12 key or to use public and private kays instead.

__Note:__ If `EXPORTED_KEYS` is set to `true` than `KEY_PUBLIC_PATH` and `KEY_PRIVATE_PATH` have to be set.

__Note:__ On some machines the path to the certificates has to be an absolut path