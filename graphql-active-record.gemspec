# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/active_record_extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "graphql-active_record"
  spec.version       = GraphQL::ActiveRecordExtensions::VERSION
  spec.authors       = ["Brett Jurgens"]
  spec.email         = ["brett@brettjurgens.com"]

  spec.summary       = "Active Record Helpers for graphql-ruby"
  spec.homepage      = "http://github.com/brettjurgens/graphql-active-record"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "graphql", "~> 0.8"
  spec.add_runtime_dependency "activerecord"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "codeclimate-test-reporter", '~>0.4'
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "guard", "~> 2.12"
  spec.add_development_dependency "guard-bundler", "~> 2.1"
  spec.add_development_dependency "guard-rspec", "~> 4.6.4"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "sqlite3"
end
