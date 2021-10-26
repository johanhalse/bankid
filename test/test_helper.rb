# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bankid"
require "bankid/authentication"
require "bankid/poll"

require "minitest/autorun"
require "webmock/minitest"
