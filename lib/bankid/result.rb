# frozen_string_literal: true

module Bankid
  Result = Struct.new(:order_ref, :status, :hint_code, :completion_data, :error_code, :details) do
    def state
      return :failed if error_code

      status.to_sym
    end

    def respond_to_missing?(method, *)
      method =~ /(\w+)\?/ || super
    end

    def method_missing(method_name)
      "#{state}?".to_sym == method_name
    end
  end
end
