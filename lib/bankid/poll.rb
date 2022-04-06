# frozen_string_literal: true

module Bankid
  class Poll
    ATTRS = %i[order_ref status hint_code completion_data error_code details].freeze
    attr_accessor(*ATTRS)

    # rubocop:disable Metrics/ParameterLists
    def initialize(order_ref: nil, status: nil, hint_code: nil, completion_data: {}, error_code: nil, details: nil)
      @order_ref = order_ref
      @status = status
      @hint_code = hint_code
      @completion_data = completion_data
      @error_code = error_code
      @details = details
    end
    # rubocop:enable Metrics/ParameterLists

    def completed?
      status == "complete"
    end

    def failed?
      status == "failed" || error_code
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
