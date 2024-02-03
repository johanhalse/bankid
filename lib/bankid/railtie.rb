# frozen_string_literal: true

module Bankid
  class Railtie < ::Rails::Railtie
    config.bankid = ActiveSupport::OrderedOptions.new

    initializer "bankid" do |app|
      Bankid.config = app.config.bankid
      path = "#{Bundler.rubygems.find_name("bankid").first.full_gem_path}/config/locales/#{I18n.locale}.yml"
      I18n.load_path += [path]
    end
  end
end
