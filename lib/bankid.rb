# frozen_string_literal: true

require "http"
require "pry"
require "rqrcode"
require_relative "bankid/authentication"
require_relative "bankid/poll"
require_relative "bankid/version"

module Bankid
  TEST_URL = "https://appapi2.test.bankid.com/rp/v5.1"
  PRODUCTION_URL = "https://appapi2.bankid.com/rp/v5.1"

  class Error < StandardError; end

  class Auth
    def initialize
      @cert, @root_cert = load_certificates
    end

    def generate_qr(start_token:, start_secret:, seconds:)
      RQRCode::QRCode.new(
        qr_auth_code(start_token, start_secret, seconds)
      )
    end

    def poll(order_ref:)
      response = HTTP
                 .headers("Content-Type": "application/json")
                 .post("#{TEST_URL}/collect", ssl_context: ssl_context, json: { orderRef: order_ref }).to_s

      Poll.new(**camelize(JSON.parse(response)))
    end

    def generate_authentication(ip:, id_number: nil)
      response = HTTP
                 .headers("Content-Type": "application/json")
                 .post("#{TEST_URL}/auth", ssl_context: ssl_context, json: auth_data(ip, id_number)).to_s

      Authentication.new(**camelize(JSON.parse(response)))
    end

    private

    def auth_data(ip, id_number)
      { endUserIp: ip }.merge(id_number ? { id_number: id_number } : {})
    end

    def camelize(response)
      response.transform_keys { |k| underscore(k.to_s).to_sym }
    end

    def cert_path(file)
      File.absolute_path("./config/certs/#{file}")
    end

    def load_certificates
      [
        OpenSSL::PKCS12.new(File.read(cert_path("FPTestcert3_20200618.p12")), "qwerty123"),
        OpenSSL::X509::Certificate.new(File.read(cert_path("bankid_test_certificate.pem")))
      ]
    end

    def qr_auth_code(start_token, start_secret, seconds)
      auth_code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), start_secret, seconds.to_s)

      "bankid.#{start_token}.#{seconds}.#{auth_code}"
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

    def underscore(str)
      str.gsub(/::/, "/")
         .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .tr("-", "_")
         .downcase
    end
  end
end
