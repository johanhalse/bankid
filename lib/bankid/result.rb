# frozen_string_literal: true

module Bankid
  class User
    attr_accessor :personal_number, :name, :given_name, :surname

    def initialize(personalNumber:, name:, givenName:, surname:)
      @personal_number = personalNumber
      @name = name
      @given_name = givenName
      @surname = surname
    end
  end

  class Device
    attr_accessor :device, :bankid_issue_date, :signature, :ocsp_response

    def initialize(device:, bankIdIssueDate:, signature:, ocspResponse:)
      @device = device
      @bankid_issue_date = bankIdIssueDate
      @signature = signature
      @ocsp_response = ocspResponse
    end

    def to_json(*_args)
      { device:, bankid_issue_date:, signature:, ocsp_response: }.to_json
    end
  end

  class Result
    attr_accessor :user, :device, :hint_code

    def initialize(result_json:)
      @result_json = result_json
      if result_json["status"] == "complete"
        set_device_and_user
      else
        set_hint_code
      end
    end

    def set_device_and_user
      @user = User.new(**@result_json.dig("completionData", "user").symbolize_keys)
      @result_json["completionData"].symbolize_keys => {
        device:,
        bankIdIssueDate:,
        signature:,
        ocspResponse:
      }
      @device = Device.new(device:, bankIdIssueDate:, signature:, ocspResponse:)
    end

    def set_hint_code
      @hint_code = @result_json["hintCode"]
    end

    def success?
      @result_json["status"] == "complete"
    end

    def failure?
      @result_json["status"] == "failed"
    end

    def pending?
      @result_json["status"] == "pending"
    end

    def user_sign?
      @result_json["status"] == "userSign"
    end

    def started?
      @result_json["status"] == "started"
    end
  end
end
