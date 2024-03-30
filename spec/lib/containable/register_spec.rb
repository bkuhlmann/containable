# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable::Register do
  subject(:register) { described_class.new dependencies }

  let(:dependencies) { {} }

  describe "#register" do
    it "registers value (plain)" do
      register.call :test, 1
      expect(dependencies).to eq("test" => 1)
    end

    it "registers value (function)" do
      register.call :test, proc { 1 }
      expect(dependencies).to match("test" => kind_of(Proc))
    end

    it "registers block" do
      register.call(:test) { 1 }
      expect(dependencies).to match("test" => kind_of(Proc))
    end

    it "registers function" do
      function = proc { 1 }
      register.call(:test, &function)

      expect(dependencies).to eq("test" => function)
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
  end

  describe "#namespace" do
    it "registers namespaced dependency" do
      register.namespace :one do
        namespace :two do
          call :three, 3
        end
      end

      expect(dependencies).to eq("one.two.three" => 3)
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

      expect(dependencies).to eq("one.two.three" => 3, "one.four.five" => 5)
    end

    it "does nothing without block" do
      register.namespace :one
      expect(dependencies).to eq({})
    end
  end
end
