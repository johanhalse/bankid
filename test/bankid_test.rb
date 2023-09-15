# frozen_string_literal: true

require "test_helper"

class BankidTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bankid::VERSION
  end

  def test_it_gets_a_proper_authentication_object_back
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/auth")
      .to_return(status: 200, body: File.read("test/fixtures/auth_success.json"))
    bankid = Bankid::Auth.new
    auth = bankid.generate_authentication(ip: "192.168.0.1")

    assert_equal(
      Bankid::Authentication.new(
        order_ref: "131daac9-16c6-4618-beb0-365768f37288",
        auto_start_token: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
        qr_start_token: "67df3917-fa0d-44e5-b327-edcc928297f8",
        qr_start_secret: "d28db9a7-4cde-429e-a983-359be676944c"
      ),
      auth
    )
  end

  def test_it_gets_a_pending_result_object_back
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/collect")
      .to_return(status: 200, body: File.read("test/fixtures/collect_pending.json"))
    bankid = Bankid::Auth.new
    result = bankid.poll(order_ref: "131daac9-16c6-4618-beb0-365768f37288")

    assert_equal(
      Bankid::Result.new(
        order_ref: "131daac9-16c6-4618-beb0-365768f37288",
        status: "pending",
        hint_code: "userSign"
      ),
      result
    )
    assert result.pending?
    refute result.completed?
    refute result.failed?
  end

  def test_it_shows_a_result_as_failed
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/collect")
      .to_return(status: 200, body: File.read("test/fixtures/collect_error.json"))
    bankid = Bankid::Auth.new
    result = bankid.poll(order_ref: "131daac9-16c6-4618-beb0-365768f37288")

    assert_equal(
      Bankid::Result.new(
        order_ref: "131daac9-16c6-4618-beb0-365768f37288",
        status: "failed",
        hint_code: "userCancel"
      ),
      result
    )
  end
end
