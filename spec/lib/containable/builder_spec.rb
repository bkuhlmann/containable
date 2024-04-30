# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable::Builder do
  subject(:container) { Module.new { extend Containable::Builder.new } }

  it_behaves_like "a container"
end
