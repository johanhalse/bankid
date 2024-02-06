# frozen_string_literal: true

module Bankid
  class Client
    def initialize
      @environment = Bankid.config.environment
      raise EnvironmentNotSetError unless %i[development production].include?(@environment)

      @url = @environment == :production ? Bankid::PRODUCTION_URL : Bankid::DEVELOPMENT_URL
      @cert_password = Bankid.config.cert_password
      @cert, @key, @root_cert = load_certificates
    end

    def auth(ip:, visible_data:)
      request("auth", auth_data(ip:, visible_data:))
    end

    def cancel(id:)
      request("cancel", orderRef: id)
    end

    def sign(ip:, visible_data:)
      request("sign", auth_data(ip:, visible_data:))
    end

    def collect(order_ref:)
      request("collect", orderRef: order_ref)
    end

    private

    def request(endpoint, data)
      HTTP
        .headers("Content-Type": "application/json")
        .post("#{@url}/#{endpoint}", ssl_context:, json: data)
        .parse
    end

    def auth_data(ip:, visible_data:)
      return { endUserIp: ip } if visible_data.nil?

      { endUserIp: ip, userVisibleData: Base64.encode64(visible_data) }
    end

    def cert_path(file)
      return File.absolute_path("./config/certs/#{file}") if @environment == :production

      "#{Bundler.rubygems.find_name("bankid").first.full_gem_path}/config/certs/#{file}"
    end

    def load_certificates
      [
        OpenSSL::X509::Certificate.new(File.read(cert_path("client_certificate.pem"))),
        OpenSSL::PKey::RSA.new(File.read(cert_path("client_certificate.key")), @cert_password),
        OpenSSL::X509::Certificate.new(File.read(cert_path("bankid_certificate.pem")))
      ]
    rescue Errno::ENOENT => _e
      raise MissingCertificatesError
    end

    def ssl_context
      OpenSSL::SSL::SSLContext.new.tap do |ctx|
        ctx.add_certificate(
          @cert,
          @key,
          [@root_cert]
        )
      end
    end
  end
end
