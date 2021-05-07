# -*- encoding: utf-8 -*-
require './lib/xmlmunger/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'xmlmunger'
  s.version     = XMLMunger::VERSION
  s.date        = Date.today.to_s
  s.summary     = 'Convert XML files into flat hashes with automatic naming via nested paths'
  s.description = %(XML files typically come in nested structures. For data extraction purposes,
    we frequently wish to have a flat hash instead. The naming then becomes tricky, because
    there can be collision in the terminal nodes. However, if we use the chain of parent tags
    joined with an underscore, this provides a unique name for every data point in the XML file.
    The goal of this package is to make it very simple to convert XML files into flat hashes.
  ).strip.gsub(/\s+/, " ")
  s.authors     = ["Robert Krzyzanowski", "David Feldman"]
  s.email       = 'rkrzyzanowski@gmail.com'
  s.homepage    = 'http://avantcredit.com'
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/robertzk/xmlmunger'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.require_paths = %w[lib]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency 'nokogiri', '>= 1.6.1'
  s.add_dependency 'nori', '>= 2.3.0'
  s.add_dependency 'descriptive_statistics', '>= 1.1.5'

  s.add_development_dependency 'rake', '>= 0.9.0'
  s.add_development_dependency 'test-unit', '>= 1.2.3'
  s.add_development_dependency 'codeclimate-test-reporter'

  s.extra_rdoc_files = ['README.md', 'LICENSE']
end

