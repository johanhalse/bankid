# frozen_string_literal: true

module Bankid
  class Secret
    RESOLUTION = 1

    attr_reader :result, :order_ref

    def initialize(orderRef:, autoStartToken:, qrStartToken:, qrStartSecret:, created_at:)
      @order_ref = orderRef
      @auto_start_token = autoStartToken
      @qr_start_token = qrStartToken
      @qr_start_secret = qrStartSecret
      @created_at = created_at
    end

    def autostart_link(return_url)
      "https://app.bankid.com/?autostarttoken=#{@auto_start_token}" "&redirect=#{return_url}"
    end

    def desktop_link(return_url)
      "bankid:///?autostarttoken=#{@auto_start_token}&redirect=#{CGI.escape(return_url)}"
    end

    def elapsed_seconds
      ((Time.zone.now - @created_at).to_f / RESOLUTION).floor * RESOLUTION
    end

    def qr_code
      auth_code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), @qr_start_secret, elapsed_seconds.to_s)
      RQRCode::QRCode.new("bankid.#{@qr_start_token}.#{elapsed_seconds}.#{auth_code}")
    end
  end
end
