require 'fiscalizer'
require 'pathname'
require 'pry'
require 'securerandom'
require 'rspec/xsd'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

root_path = Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
Dir[root_path.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include RSpec::XSD
end
