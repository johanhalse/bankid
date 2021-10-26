# frozen_string_literal: true

module Bankid
  class Poll
    ATTRS = %i[order_ref status hint_code completion_data].freeze
    attr_accessor(*ATTRS)

    def initialize(order_ref:, status:, hint_code: nil, completion_data: {})
      @order_ref = order_ref
      @status = status
      @hint_code = hint_code
      @completion_data = completion_data
    end

    def completed?
      status == "complete"
    end

    def failed?
      status == "failed"
    end

    def to_h
      ATTRS.map { |a| [a, send(a)] }.to_h
    end

    def ==(other)
      ATTRS.all? { |a| send(a) == other.send(a) }
    end
  end
end
