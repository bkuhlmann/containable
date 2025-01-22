# frozen_string_literal: true

require "concurrent/hash"

module Containable
  # Resolves previously registered dependencies.
  class Resolver
    def initialize dependencies = Concurrent::Hash.new
      @dependencies = dependencies
    end

    def call key
      tuple = fetch key
      value, as = tuple

      return value unless value.is_a?(Proc) && value.arity.zero?

      process key, value, as
    end

    private

    attr_reader :dependencies

    def fetch key
      dependencies.fetch key.to_s do
        fail KeyError, "Unable to resolve dependency: #{key.inspect}."
      end
    end

    def process key, closure, directive
      value = closure.call
      dependencies[key.to_s] = [value, directive] if directive == :cache

      value
    end
  end
end
