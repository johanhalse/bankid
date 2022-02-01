# frozen_string_literal: true

require "http"
require "rqrcode"
require_relative "bankid/authentication"
require_relative "bankid/poll"
require_relative "bankid/version"

module Bankid
  TEST_URL = "http://127.0.0.1"
  DEVELOPMENT_URL = "https://appapi2.test.bankid.com/rp/v5.1"
  PRODUCTION_URL = "https://appapi2.bankid.com/rp/v5.1"

  class Error < StandardError; end

  class Auth
    def self.stub_endpoint(endpoint, data)
      @stubs = {} unless defined?(@stubs)
      @stubs[endpoint] = data
    end

    def self.endpoint_stub(endpoint)
      unless defined?(@stubs)
        raise "You should stub the endpoint `#{endpoint}` with the `Bankid::Auth.stub_endpoint` method"
      end

      @stubs[endpoint]
    end

    def self.clear_stubs
      remove_instance_variable(:@stubs) if defined?(@stubs)
    end

    def initialize(env: "development", cert_password: "qwerty123")
      @stubs = []
      @env = env
      @url = Bankid.const_get("#{env.upcase}_URL")
      @cert_password = cert_password
      @cert, @root_cert = load_certificates
    end

    def generate_qr(start_token:, start_secret:, seconds:)
      RQRCode::QRCode.new(
        qr_auth_code(start_token, start_secret, seconds)
      )
    end

    def poll(order_ref:)
      response = request("collect", { orderRef: order_ref })
      Poll.new(**camelize(JSON.parse(response)))
    end

    def generate_authentication(ip:, id_number: nil)
      response = request("auth", auth_data(ip, id_number))
      Authentication.new(**camelize(JSON.parse(response)))
    end

    private

    def request(endpoint, data)
      return Auth.endpoint_stub(endpoint) if @env == "test"

      HTTP
        .headers("Content-Type": "application/json")
        .post("#{@url}/#{endpoint}", ssl_context: ssl_context, json: data).to_s
    end

    def auth_data(ip, id_number)
      { endUserIp: ip }.merge(id_number ? { id_number: id_number } : {})
    end

    def camelize(response)
      response.transform_keys { |k| underscore(k.to_s).to_sym }
    end

    def cert_path(file)
      File.absolute_path("./config/certs/#{@env}_#{file}")
    end

    def load_certificates
      return if @env == "test"

      [
        OpenSSL::PKCS12.new(File.read(cert_path("client_certificate.p12")), @cert_password),
        OpenSSL::X509::Certificate.new(File.read(cert_path("bankid_certificate.pem")))
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
