# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fiscalizer/version'

Gem::Specification.new do |spec|
  spec.name          = "fiscalizer"
  spec.version       = Fiscalizer::VERSION
  spec.authors       = ["Stanko Krtalić Rusendić"]
  spec.email         = ["stanko.krtalic-rusendic@infinum.hr"]
  spec.description   = %q{Automatic fiscalization}
  spec.summary       = %q{A gem that automatically handles fiscalization}
  spec.homepage      = "https://github.com/infinum/fiscalizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency             "nokogiri"
  #spec.add_dependency 			  "xmldsig"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
