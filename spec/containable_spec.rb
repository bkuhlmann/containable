# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable do
  subject(:container) { Module.new { extend Containable } }

  describe ".extended" do
    it_behaves_like "a container"
  end

  describe ".[]" do
    subject :container do
      Module.new do
        extend Containable[register: Containable::Register, resolver: Containable::Resolver]
      end
    end

    it_behaves_like "a container"
  end

  describe ".stub!" do
    subject :container do
      stub_const "Test::Container", Module.new.extend(described_class)
    end

    before do
      container.register(:one) { 1 }
      container.register(:two, {a: 1, b: 2})
      container.stub! two: 2
    end

    it_behaves_like "a stub"

    it "answers primary stub" do
      expect(container["two"]).to eq(2)
    end
  end

  describe "#restore" do
    it "answers false" do
      expect(container.restore).to be(false)
    end
  end
end
