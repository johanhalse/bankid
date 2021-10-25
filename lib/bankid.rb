# frozen_string_literal: true

require "http"
require "pry"
require "rqrcode"
require_relative "bankid/version"

module Bankid
  TEST_URL = "https://appapi2.test.bankid.com/rp/v5.1/auth"
  PRODUCTION_URL = "https://appapi2.bankid.com/rp/v5.1/auth"

  class Error < StandardError; end

  Authentication = Struct.new(:order_ref, :auto_start_token, :qr_start_token, :qr_start_secret, keyword_init: true)

  class Auth
    def initialize
      @cert, @root_cert = load_certificates
    end

    def load_certificates
      [
        OpenSSL::PKCS12.new(File.read(cert_path("FPTestcert3_20200618.p12")), "qwerty123"),
        OpenSSL::X509::Certificate.new(File.read(cert_path("bankid_test_certificate.pem")))
      ]
    end

    def cert_path(file)
      File.absolute_path("./config/certs/#{file}")
    end

    def generate_qr(start_token:, start_secret:, seconds:)
      RQRCode::QRCode.new(
        qr_auth_code(start_token, start_secret, seconds)
      )
    end

    def generate_authentication(ip:, id_number: nil)
      response = JSON.parse(
        HTTP
          .headers("Content-Type": "application/json")
          .post(TEST_URL, ssl_context: ssl_context, json: data(ip, id_number)).to_s
      )

      Authentication.new(camelize(response))
    end

    def camelize(response)
      response.transform_keys { |k| k.to_s.underscore }
    end

    def qr_auth_code(start_token, start_secret, seconds)
      auth_code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), start_secret, seconds.to_s)

      "bankid.#{start_token}.#{seconds}.#{auth_code}"
    end

    def data(ip, id_number)
      { endUserIp: ip }.merge(
        id_number ? { id_number: id_number } : {}
      )
    end

    def ssl_context
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.add_certificate(
          @cert.certificate,
          @cert.key,
          [@root_cert]
        )
      end
    end
  end
end
