# frozen_string_literal: true

require "concurrent/hash"

module Containable
  # :reek:TooManyInstanceVariables
  # Registers dependencies for future evaluation.
  class Register
    SEPARATOR = "."
    DIRECTIVES = %i[cache fresh].freeze

    def initialize dependencies = Concurrent::Hash.new, separator: SEPARATOR, directives: DIRECTIVES
      @dependencies = dependencies
      @separator = separator
      @directives = directives
      @keys = []
      @depth = 0
    end

    def call key, value = nil, as: :cache, &block
      warn "Registration of value is ignored since block takes precedence." if value && block

      namespaced_key = namespacify key

      check_duplicate key, namespaced_key
      check_directive as
      dependencies[namespaced_key] = [block || value, as]
    end

    alias register call

    def namespace(name, &)
      keys.clear if depth.zero?
      keys.append name
      visit(&)
    end

    private

    attr_reader :dependencies, :separator, :directives

    attr_accessor :keys, :depth

    def check_duplicate key, namespaced_key
      message = "Dependency is already registered: #{key.inspect}."

      fail KeyError, message if dependencies.key? namespaced_key
    end

    def check_directive value
      return if directives.include? value

      fail ArgumentError,
           %(Invalid directive: #{value.inspect}. Use #{directives.map(&:inspect).join " or "}.)
    end

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
