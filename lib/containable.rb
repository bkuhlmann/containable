# frozen_string_literal: true

require "containable/builder"
require "containable/register"
require "containable/resolver"

# Main namespace.
module Containable
  def self.extended descendant
    super
    descendant.extend Builder.new
  end

  def self.[](register: Register, resolver: Resolver) = Builder.new(register:, resolver:)

  def stub!(**)
    require "containable/test"

    extend Test

    stub(**)
  end

  def restore = false
end
