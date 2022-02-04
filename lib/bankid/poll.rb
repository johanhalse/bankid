# frozen_string_literal: true

module Bankid
  class Poll
    ATTRS = %i[order_ref status hint_code completion_data].freeze
    attr_accessor(*ATTRS)

    def initialize(order_ref: nil, status: nil, hint_code: nil, completion_data: {})
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

    def timed_out?
      hint_code == "startFailed"
    end

    def to_h
      ATTRS.to_h { |a| [a, send(a)] }
    end

    def ==(other)
      ATTRS.all? { |a| send(a) == other.send(a) }
    end
  end
end
