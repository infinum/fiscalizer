require 'fiscalizer'
require 'pathname'
require 'pry'
require 'securerandom'
require 'webmock/rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

root_path = Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
Dir[root_path.join('spec/support/**/*.rb')].each { |f| require f }

public

def get_response_file(file)
  "spec/support/responses/#{file}"
end
