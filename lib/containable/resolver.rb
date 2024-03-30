# frozen_string_literal: true

require "concurrent/hash"

module Containable
  # Resolves previously registered dependencies.
  class Resolver
    def initialize dependencies = Concurrent::Hash.new
      @dependencies = dependencies
    end

    def call key
      normalized_key = key.to_s

      value = dependencies.fetch normalized_key do
        fail KeyError, "Unable to resolve dependency: #{key.inspect}."
      end

      value.is_a?(Proc) && value.arity.zero? ? dependencies[normalized_key] = value.call : value
    end

    private

    attr_reader :dependencies
  end
end
