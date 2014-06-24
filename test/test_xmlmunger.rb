if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
require 'test/unit'
load 'test_nested_hash.rb'
load 'test_parser.rb'
