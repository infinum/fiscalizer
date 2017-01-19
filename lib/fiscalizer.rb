require 'bundler/setup'
require 'uri'
require 'net/http'
require 'openssl'
require 'nokogiri'
require 'xmldsig_fiscalizer'

require 'fiscalizer/version'
require 'fiscalizer/fiscalizer'

require 'fiscalizer/constants'

require 'fiscalizer/data_objects/echo'
require 'fiscalizer/data_objects/invoice'
require 'fiscalizer/data_objects/office'
require 'fiscalizer/data_objects/tax'
require 'fiscalizer/data_objects/fee'

require 'fiscalizer/fiscalizers/base'
require 'fiscalizer/fiscalizers/echo'
require 'fiscalizer/fiscalizers/invoice'
require 'fiscalizer/fiscalizers/office'

require 'fiscalizer/serializers/base'
require 'fiscalizer/serializers/echo'
require 'fiscalizer/serializers/invoice'
require 'fiscalizer/serializers/office'
require 'fiscalizer/serializers/signature'
require 'fiscalizer/serializers/tax'

require 'fiscalizer/deserializers/base'
require 'fiscalizer/deserializers/echo'
require 'fiscalizer/deserializers/invoice'
require 'fiscalizer/deserializers/office'

require 'fiscalizer/services/request_sender'
require 'fiscalizer/services/security_code_generator'
