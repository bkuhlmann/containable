# frozen_string_literal: true

require "containable/register"
require "containable/resolver"
require "containable/vault"

# Main namespace.
module Containable
  def self.extended descendant
    super
    descendant.extend Vault.new
  end

  def self.[](register: Register, resolver: Resolver) = Vault.new(register:, resolver:)

  def stub!(**)
    require "containable/test"
    extend Test
    stub(**)
  end
end
