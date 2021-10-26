# frozen_string_literal: true

module Bankid
  class Authentication
    ATTRS = %i[order_ref auto_start_token qr_start_token qr_start_secret].freeze
    attr_accessor(*ATTRS)

    def initialize(order_ref:, auto_start_token:, qr_start_token:, qr_start_secret:)
      @order_ref = order_ref
      @auto_start_token = auto_start_token
      @qr_start_token = qr_start_token
      @qr_start_secret = qr_start_secret
    end

    def ==(other)
      ATTRS.all? { |a| send(a) == other.send(a) }
    end
  end
end
