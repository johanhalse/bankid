# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bankid"

require "pry"
require "minitest/autorun"
require "webmock/minitest"

def bankid_fixture(name)
  JSON.load_file("test/fixtures/#{name}.json").transform_keys { |k| underscore(k.to_s).to_sym }
end

def underscore(str)
  str.gsub("::", "/")
     .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
     .gsub(/([a-z\d])([A-Z])/, '\1_\2')
     .tr("-", "_")
     .downcase
end
