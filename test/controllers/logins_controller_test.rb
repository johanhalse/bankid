# frozen_string_literal: true

require "test_helper"

class LoginsControllerTest < ActionDispatch::IntegrationTest
  test "can request new authentication from bankid" do
    VCR.use_cassette("bankid_new_authentication", serialize_with: :json) do
      get new_login_path
    end
    assert_redirected_to login_path("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e")
  end

  test "can collect a pending response via order ref" do
    Rails.cache.write("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e", cached_secret)
    VCR.use_cassette("bankid_collect_authentication_pending", serialize_with: :json) do
      get login_path("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e")
    end
    assert_select "svg"
  end

  test "can collect a successful response via order ref and create a user" do
    Rails.cache.write("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e", cached_secret)
    VCR.use_cassette("bankid_collect_authentication_successful", serialize_with: :json) do
      get login_path("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e")
    end
    assert_equal "Login successful!", flash[:notice]
    assert_equal Signature.first.name, "Karl Karlsson"
    assert_equal Signature.first.device, "{}"
    assert_redirected_to root_path
  end

  test "can collect a failed response via order ref" do
    Rails.cache.write("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e", cached_secret)
    VCR.use_cassette("bankid_collect_authentication_failure", serialize_with: :json) do
      get login_path("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e")
    end
    assert_equal(
      "The BankID you are trying to use is blocked or too old. \
      Please use another BankID or get a new one from your bank.".squish,
      flash[:notice]
    )
    assert_redirected_to root_path
  end

  test "can cancel ongoing login" do
    VCR.use_cassette("bankid_cancel_authentication", serialize_with: :json) do
      delete login_path("bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e")
    end
    assert_equal "Login cancelled.", flash[:notice]
    assert_redirected_to root_path
  end

  private

  def cached_secret
    {
      orderRef: "bfbfa57b-5f63-43cd-8d5f-5d3b4fc2995e",
      autoStartToken: "bf82d927-31d4-46e3-90eb-ed26fe9a4512",
      qrStartToken: "eb4b760a-415c-4c41-b429-9dffabacd059",
      qrStartSecret: "90ebd474-d97a-4c5d-86d8-84b165b06f5b",
      created_at: 10.seconds.ago
    }
  end
end
