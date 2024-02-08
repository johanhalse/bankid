# frozen_string_literal: true

require "http"
require "rqrcode"
require "bankid/version"
require "bankid/client"
require "bankid/result"
require "bankid/secret"
require "bankid/railtie" if defined?(Rails::Railtie)

module Bankid
  DEVELOPMENT_URL = "https://appapi2.test.bankid.com/rp/v5.1"
  PRODUCTION_URL = "https://appapi2.bankid.com/rp/v5.1"

  class EnvironmentNotSetError < StandardError; end
  class MissingCertificatesError < StandardError; end
  class CachedSecretNotFoundError < StandardError; end
  class NoSuchOrderError < StandardError; end

  def self.config
    @@config
  end

  def self.config=(config)
    @@config = config
  end

  def self.cancel(id)
    Client.new.cancel(id:)
  end

  def self.collect(id)
    cached_secret = Rails.cache.read(id)
    raise CachedSecretNotFoundError if cached_secret.nil?

    result_json = Client.new.collect(order_ref: id)
    raise NoSuchOrderError if result_json["errorCode"].present?

    [Secret.new(**cached_secret.symbolize_keys), Result.new(result_json:)]
  end

  def self.generate_authentication(ip:, visible_data: nil)
    response = Client.new.auth(ip:, visible_data:).merge(created_at: Time.zone.now)
    Rails.cache.write(response["orderRef"], response, expires_in: 1.minute)
    response["orderRef"]
  end

  def self.generate_signature(ip:, visible_data: nil)
    response = Client.new.sign(ip:, visible_data:).merge(created_at: Time.zone.now)
    Rails.cache.write(response["orderRef"], response, expires_in: 1.minute)
    response["orderRef"]
  end

  def self.translated_hint_code(hint_code)
    I18n.translate("bankid.hints.#{hint_code}")
  end
end
