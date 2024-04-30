# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable::Builder do
  subject(:container) { Module.new { extend Containable::Builder.new } }

  describe "#initalize" do
    it "is frozen" do
      builder = described_class.new
      expect(builder.frozen?).to be(true)
    end
  end

  it_behaves_like "a container"
end
