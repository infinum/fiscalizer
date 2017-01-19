class Fiscalizer
  module Constants
    DEMO_URL = 'https://cistest.apis-it.hr:8449/FiskalizacijaServiceTest'
    PROD_URL = 'https://cis.porezna-uprava.hr:8449/FiskalizacijaService'
    TNS = 'http://www.apis-it.hr/fin/2012/types/f73'
    XSI = 'http://www.w3.org/2001/XMLSchema-instance'
    SCHEMA_LOCATION = 'http://www.apis-it.hr/fin/2012/types/f73 FiskalizacijaSchema.xsd'
    DEMO_CERT_ISSUER = 'OU=DEMO,O=FINA,C=HR'
    PROD_CERT_ISSUER = 'OU=RDC,O=FINA,C=HR'
  end
end
