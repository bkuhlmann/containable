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
end
