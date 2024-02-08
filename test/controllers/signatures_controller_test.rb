# frozen_string_literal: true

require "test_helper"

class SignaturesControllerTest < ActionDispatch::IntegrationTest
  test "can request new signature from bankid" do
    VCR.use_cassette("bankid_new_signature", serialize_with: :json) do
      get new_signature_path
    end
    assert_redirected_to signature_path("a39b5ce4-b7cc-48af-ab09-934db3a54e44")
  end

  test "can collect a pending response via order ref" do
    Rails.cache.write("a39b5ce4-b7cc-48af-ab09-934db3a54e44", cached_secret)
    VCR.use_cassette("bankid_collect_signature_pending", serialize_with: :json) do
      get signature_path("a39b5ce4-b7cc-48af-ab09-934db3a54e44")
    end
    assert_select "svg"
  end

  test "can collect a successful response via order ref and create a signature" do
    Rails.cache.write("a39b5ce4-b7cc-48af-ab09-934db3a54e44", cached_secret)
    VCR.use_cassette("bankid_collect_signature_successful", serialize_with: :json) do
      get signature_path("a39b5ce4-b7cc-48af-ab09-934db3a54e44")
    end
    assert_equal "Successfully signed!", flash[:notice]
    assert_equal Signature.count, 1
    assert_redirected_to root_path
  end

  test "can collect a failed response via order ref" do
    Rails.cache.write("a39b5ce4-b7cc-48af-ab09-934db3a54e44", cached_secret)
    VCR.use_cassette("bankid_collect_signature_failure", serialize_with: :json) do
      get signature_path("a39b5ce4-b7cc-48af-ab09-934db3a54e44")
    end
    assert_equal "Action cancelled.", flash[:notice]
    assert_redirected_to root_path
  end

  test "raises " do
    assert_raises Bankid::CachedSecretNotFoundError do
      get signature_path("c39b5ce4-b7cc-48af-ab09-934db3a54e44")
    end
  end

  private

  def cached_secret
    {
      orderRef: "a39b5ce4-b7cc-48af-ab09-934db3a54e44",
      autoStartToken: "bf82d927-31d4-46e3-90eb-ed26fe9a4512",
      qrStartToken: "eb4b760a-415c-4c41-b429-9dffabacd059",
      qrStartSecret: "90ebd474-d97a-4c5d-86d8-84b165b06f5b",
      created_at: 10.seconds.ago
    }
  end
end
