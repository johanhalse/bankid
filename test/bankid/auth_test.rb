# frozen_string_literal: true

require "test_helper"

module BankId
  class AuthTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Bankid::VERSION
    end
  end
end
