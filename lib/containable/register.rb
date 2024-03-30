# frozen_string_literal: true

require "concurrent/hash"

module Containable
  # Registers dependencies for future evaluation.
  class Register
    SEPARATOR = "."

    def initialize dependencies = Concurrent::Hash.new, separator: SEPARATOR
      @dependencies = dependencies
      @separator = separator
      @keys = []
      @depth = 0
    end

    def call key, value = nil, &block
      namespaced_key = namespacify key
      message = "Dependency is already registered: #{key.inspect}."

      warn "Registration of value is ignored since block takes precedence." if value && block
      fail KeyError, message if dependencies.key? namespaced_key

      dependencies[namespaced_key] = block || value
    end

    alias register call

    def namespace(name, &)
      keys.clear if depth.zero?
      keys.append name
      visit(&)
    end

    private

    attr_reader :dependencies, :separator

    attr_accessor :keys, :depth

    def visit &block
      increment
      instance_eval(&block) if block
      keys.pop
      decrement
    end

    def increment = self.depth += 1

    def decrement = self.depth -= 1

    def namespacify(key) = keys[..depth].append(key).join separator
  end
end
