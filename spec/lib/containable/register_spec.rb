# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable::Register do
  subject(:register) { described_class.new dependencies }

  let(:dependencies) { {} }

  describe "#register" do
    it "registers primitive" do
      register.call :test, 1
      expect(dependencies).to eq("test" => [1, :cache])
    end

    it "registers block" do
      register.call(:test) { 1 }
      expect(dependencies).to match("test" => [kind_of(Proc), :cache])
    end

    it "registers function" do
      register.call :test, proc { 1 }
      expect(dependencies).to match("test" => [kind_of(Proc), :cache])
    end

    it "registers function as block" do
      function = proc { 1 }
      register.call(:test, &function)

      expect(dependencies).to eq("test" => [function, :cache])
    end

    it "warns when value and block are present" do
      expectation = proc { register.call(:test, 1) { 2 } }
      expect(&expectation).to output(/Registration of value is ignored/).to_stderr
    end

    it "fails when key exists" do
      register.call :test, 1
      expectation = proc { register.call :test, 1 }

      expect(&expectation).to raise_error(KeyError, "Dependency is already registered: :test.")
    end

    it "fails with invalid directive" do
      expectation = proc { register.call(:test, as: :bogus) { Object.new } }

      expect(&expectation).to raise_error(
        ArgumentError,
        "Invalid directive: :bogus. Use :cache or :fresh."
      )
    end
  end

  describe "#namespace" do
    it "registers cached namespaced dependency" do
      register.namespace :one do
        namespace :two do
          call :three, 3
        end
      end

      expect(dependencies).to eq("one.two.three" => [3, :cache])
    end

    it "registers fresh namespaced dependency" do
      register.namespace :one do
        namespace :two do
          call :three, 3, as: :fresh
        end
      end

      expect(dependencies).to eq("one.two.three" => [3, :fresh])
    end

    it "registers multiple namespaced dependencies" do
      register.namespace :one do
        namespace :two do
          call :three, 3
        end

        namespace :four do
          call :five, 5
        end
      end

      expect(dependencies).to eq("one.two.three" => [3, :cache], "one.four.five" => [5, :cache])
    end

    it "does nothing without block" do
      register.namespace :one
      expect(dependencies).to eq({})
    end
  end
end
