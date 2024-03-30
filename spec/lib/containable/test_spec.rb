# frozen_string_literal: true

require "containable/test"
require "spec_helper"

RSpec.describe Containable::Test do
  subject(:container) { stub_const "Test::Container", Module.new.extend(Containable) }

  before do
    container.register(:one) { 1 }
    container.register(:two, {a: 1, b: 2})
    container.extend described_class
  end

  it_behaves_like "a stub"
end
