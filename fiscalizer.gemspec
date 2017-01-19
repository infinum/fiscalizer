# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fiscalizer/version'

Gem::Specification.new do |spec|
  spec.name          = 'fiscalizer'
  spec.version       = Fiscalizer::VERSION
  spec.authors       = ['Stanko Krtalić Rusendić', 'Vladimir Rosančić']
  spec.email         = ['stanko.krtalic@gmail.com', 'vladimir.rosancic@infinum.hr']
  spec.description   = 'Automatic fiscalization'
  spec.summary       = 'A gem that automatically handles fiscalization'
  spec.homepage      = 'https://github.com/infinum/fiscalizer'
  spec.license       = 'MIT'
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'xmldsig-fiscalizer', '~> 0.2'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
end
