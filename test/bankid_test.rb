# frozen_string_literal: true

require "test_helper"

# rubocop:disable Metrics/ClassLength, Metrics/MethodLength
class BankidTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bankid::VERSION
  end

  def test_it_gets_a_proper_authentication_object_back
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/auth")
      .to_return(status: 200, body: successful_auth_response)
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

  def test_it_gets_a_pending_poll_object_back
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/collect")
      .to_return(status: 200, body: pending_collect_response)
    bankid = Bankid::Auth.new
    poll = bankid.poll(order_ref: "131daac9-16c6-4618-beb0-365768f37288")

    assert_equal(
      Bankid::Poll.new(
        order_ref: "131daac9-16c6-4618-beb0-365768f37288",
        status: "pending",
        hint_code: "userSign"
      ),
      poll
    )
    assert poll.pending?
    refute poll.completed?
    refute poll.failed?
  end

  def test_it_gets_a_successful_poll_object_back
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/collect")
      .to_return(status: 200, body: successful_collect_response)
    bankid = Bankid::Auth.new
    poll = bankid.poll(order_ref: "131daac9-16c6-4618-beb0-365768f37288")

    assert_equal(
      Bankid::Poll.new(
        order_ref: "131daac9-16c6-4618-beb0-365768f37288",
        status: "complete",
        completion_data: {
          "user" => {
            "personalNumber" => "190000000000",
            "name" => "Karl Karlsson",
            "givenName" => "Karl",
            "surname" => "Karlsson"
          },
          "device" => {
            "ipAddress" => "192.168.0.1"
          },
          "cert" => {
            "notBefore" => "1502983274000",
            "notAfter" => "1563549674000"
          },
          "signature" => "",
          "ocspResponse" => ""
        }
      ),
      poll
    )
    assert poll.completed?
    refute poll.failed?
  end

  def test_it_shows_a_poll_as_failed
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/collect")
      .to_return(status: 200, body: cancelled_collect_response)
    bankid = Bankid::Auth.new
    poll = bankid.poll(order_ref: "131daac9-16c6-4618-beb0-365768f37288")

    assert_equal(
      Bankid::Poll.new(
        order_ref: "131daac9-16c6-4618-beb0-365768f37288",
        status: "failed",
        hint_code: "userCancel"
      ),
      poll
    )
    assert poll.failed?
    refute poll.completed?
  end

  def test_poll_with_errors
    stub_request(:post, "https://appapi2.test.bankid.com/rp/v5.1/collect")
      .to_return(status: 200, body: error_collect_response)
    bankid = Bankid::Auth.new
    poll = bankid.poll(order_ref: "131daac9-16c6-4618-beb0-365768f37288")

    assert_equal(
      Bankid::Poll.new(
        error_code: "400",
        details: "Oh bother"
      ),
      poll
    )
    assert poll.failed?
    refute poll.completed?
  end

  def test_authentication_to_h
    result = {
      order_ref: "131daac9-16c6-4618-beb0-365768f37288",
      auto_start_token: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
      qr_start_token: "67df3917-fa0d-44e5-b327-edcc928297f8",
      qr_start_secret: "d28db9a7-4cde-429e-a983-359be676944c"

    }
    auth = Bankid::Authentication.new(**result)

    assert_equal(auth.to_h, result)
  end

  def test_poll_to_h
    result = {
      order_ref: "131daac9-16c6-4618-beb0-365768f37288",
      status: "failed",
      hint_code: "userCancel"
    }
    poll = Bankid::Poll.new(**result)

    assert_equal(poll.to_h, result.merge({ completion_data: {}, error_code: nil, details: nil }))
  end

  def successful_auth_response
    JSON.dump(
      {
        orderRef: "131daac9-16c6-4618-beb0-365768f37288",
        autoStartToken: "7c40b5c9-fa74-49cf-b98c-bfe651f9a7c6",
        qrStartToken: "67df3917-fa0d-44e5-b327-edcc928297f8",
        qrStartSecret: "d28db9a7-4cde-429e-a983-359be676944c"
      }
    )
  end

  def pending_collect_response
    JSON.dump(
      {
        orderRef: "131daac9-16c6-4618-beb0-365768f37288",
        status: "pending",
        hintCode: "userSign"
      }
    )
  end

  def cancelled_collect_response
    JSON.dump(
      {
        orderRef: "131daac9-16c6-4618-beb0-365768f37288",
        status: "failed",
        hintCode: "userCancel"
      }
    )
  end

  def error_collect_response
    JSON.dump(
      {
        errorCode: "400",
        details: "Oh bother"
      }
    )
  end

  def successful_collect_response
    JSON.dump(
      {
        orderRef: "131daac9-16c6-4618-beb0-365768f37288",
        status: "complete",
        completionData: {
          user: {
            personalNumber: "190000000000",
            name: "Karl Karlsson",
            givenName: "Karl",
            surname: "Karlsson"
          },
          device: {
            ipAddress: "192.168.0.1"
          },
          cert: {
            notBefore: "1502983274000",
            notAfter: "1563549674000"
          },
          signature: "",
          ocspResponse: ""
        }
      }
    )
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/MethodLength
