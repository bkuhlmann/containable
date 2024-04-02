# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "a stub" do
  shared_examples "a getter" do |message|
    it "answers original" do
      expect(container.public_send(message, "one")).to eq(1)
    end

    it "answers stub" do
      container.stub one: :custom
      expect(container.public_send(message, "one")).to eq(:custom)
    end
  end

  describe ".[]" do
    it_behaves_like "a getter", :[]
  end

  describe ".resolve" do
    it_behaves_like "a getter", :resolve
  end

  describe ".stub" do
    it "stubs existing dependency" do
      container.stub one: :custom
      expect(container["one"]).to eq(:custom)
    end

    it "fails when stubbing non-existent key" do
      expectation = proc { container.stub bogus: :invalid }
      expect(&expectation).to raise_error(KeyError, "Unable to stub unknown key: :bogus.")
    end
  end

  describe "#restore" do
    it "restores original dependency" do
      container.stub one: "one"
      container.restore

      expect(container["one"]).to eq(1)
    end

    it "restores original dependencies" do
      container.stub one: "one"
      container.restore

      expect(container.each.to_h).to match("one" => kind_of(Proc), "two" => {a: 1, b: 2})
    end

    it "answers true when there is something to restore" do
      container.stub one: "one"
      expect(container.restore).to be(true)
    end

    it "answers true when there is nothing to restore" do
      expect(container.restore).to be(true)
    end
  end

  describe ".stub!" do
    it "answers stubs existing dependency" do
      container.stub! one: :test
      expect(container[:one]).to eq(:test)
    end
  end
end
