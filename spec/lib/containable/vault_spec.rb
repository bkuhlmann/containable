# frozen_string_literal: true

require "spec_helper"

RSpec.describe Containable::Vault do
  subject(:container) { Module.new { extend Containable::Vault.new } }

  it_behaves_like "a container"
end
