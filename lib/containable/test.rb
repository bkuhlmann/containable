# frozen_string_literal: true

module Containable
  # Allows stubbing of dependencies for testing purposes only.
  module Test
    def resolve(key) = stubs.fetch(key.to_s) { super }

    alias [] resolve

    def stub(**overrides)
      @originals ||= dependencies.dup

      overrides.each do |key, value|
        normalized_key = key.to_s

        fail KeyError, "Unable to stub unknown key: #{key.inspect}." unless key? normalized_key

        stubs[normalized_key] = value
      end
    end

    def stub!(**) = stub(**)

    def restore
      stubs.clear
      dependencies.replace originals if originals
      true
    end

    private

    def originals = @originals

    def stubs = @stubs ||= {}
  end
end
