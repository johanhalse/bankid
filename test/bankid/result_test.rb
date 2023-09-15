# frozen_string_literal: true

require "test_helper"

module BankId
  class ResultTest < Minitest::Test
    def test_state_getters
      assert Bankid::Result.new(**bankid_fixture("collect_pending")).pending?
      assert Bankid::Result.new(**bankid_fixture("collect_error")).failed?

      refute Bankid::Result.new(**bankid_fixture("collect_error")).pending?
      refute Bankid::Result.new(**bankid_fixture("collect_pending")).failed?
    end

    def test_to_h
      assert_equal(
        Bankid::Result.new(**bankid_fixture("collect_success")).to_h,
        {
          order_ref: "131daac9-16c6-4618-beb0-365768f37288", status: "complete", hint_code: nil,
          completion_data: {
            "user" => {
              "personalNumber" => "190000000000",
              "name" => "Karl Karlsson",
              "givenName" => "Karl",
              "surname" => "Karlsson"
            },
            "device" => { "ipAddress" => "192.168.0.1" },
            "cert" => { "notBefore" => "1502983274000", "notAfter" => "1563549674000" },
            "signature" => "",
            "ocspResponse" => ""
          },
          error_code: nil, details: nil
        }
      )
    end

    def test_state
      assert_equal Bankid::Result.new(**bankid_fixture("collect_pending")).state, :pending
      assert_equal Bankid::Result.new(**bankid_fixture("collect_success")).state, :complete
      assert_equal Bankid::Result.new(**bankid_fixture("collect_error")).state, :failed
      assert_equal Bankid::Result.new(**bankid_fixture("collect_cancel")).state, :failed
    end
  end
end
