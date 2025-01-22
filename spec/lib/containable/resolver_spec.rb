# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable::Resolver do
  subject(:resolver) { described_class.new dependencies }

  let(:dependencies) { {} }

  describe "#call" do
    it "resolves cached value" do
      dependencies["test"] = [1, :cache]
      expect(resolver.call("test")).to eq(1)
    end

    it "resolves fresh value" do
      dependencies["test"] = [1, :fresh]
      expect(resolver.call("test")).to eq(1)
    end

    it "resolves fresh values and ensures they are unique" do
      dependencies["test"] = [proc { Object.new }, :fresh]
      first = resolver.call "test"
      second = resolver.call "test"

      expect(first).not_to eq(second)
    end

    it "resolves function with no arguments" do
      dependencies["test"] = [proc { 1 }, :cache]
      expect(resolver.call("test")).to eq(1)
    end

    it "does not resolve function with arguments" do
      dependencies["test"] = [-> text { text }, :cache]
      expect(resolver.call("test")).to be_a(Proc)
    end

    it "resolves dependency with symbol key" do
      dependencies["test"] = [1, :cache]
      expect(resolver.call(:test)).to eq(1)
    end

    it "fails with key error when key (string) doesn't exist" do
      expectation = proc { resolver.call :test }
      expect(&expectation).to raise_error(KeyError, %(Unable to resolve dependency: :test.))
    end

    it "fails with key error when key (symbol) doesn't exist" do
      expectation = proc { resolver.call "test" }
      expect(&expectation).to raise_error(KeyError, %(Unable to resolve dependency: "test".))
    end
  end
end
