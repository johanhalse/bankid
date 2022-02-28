# frozen_string_literal: true

module Bankid
  class Poll
    ATTRS = %i[order_ref status hint_code completion_data error_code details].freeze
    attr_accessor(*ATTRS)

    def initialize(order_ref: nil, status: nil, hint_code: nil, completion_data: {}, error_code: nil, details: nil)
      @order_ref = order_ref
      @status = status
      @status = status
      @error_code = error_code
      @details = details
      @hint_code = hint_code
      @completion_data = completion_data
      if @error_code.to_s.length > 0 && @status.to_s.length == 0
        @status = 'failed'
      end
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
