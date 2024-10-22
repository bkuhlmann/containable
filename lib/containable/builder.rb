# frozen_string_literal: true

require "concurrent/hash"

module Containable
  # Provides safe registration and resolution of dependencies.
  class Builder < Module
    def initialize dependencies = Concurrent::Hash.new, register: Register, resolver: Resolver
      super()

      @dependencies = dependencies
      @register = register.new dependencies
      @resolver = resolver.new dependencies

      private_methods.grep(/\A(define)_/).sort.each { |method| __send__ method }

      alias_method :[]=, :register
      alias_method :[], :resolve

      freeze
    end

    def extended descendant
      fail TypeError, "Only a module can be a container." if descendant.is_a? Class

      super
      descendant.class_eval "private_class_method :dependencies", __FILE__, __LINE__
    end

    private

    attr_reader :dependencies, :register, :resolver

    def define_dependencies target = dependencies
      define_method(:dependencies) { target }
    end

    def define_register target = register
      define_method :register do |key, value = nil, &block|
        fail FrozenError, "Can't modify frozen container." if dependencies.frozen?

        target.call key, value, &block
      end
    end

    def define_namespace target = register
      define_method(:namespace) { |name, &block| target.namespace name, &block }
    end

    def define_resolve target = resolver
      define_method(:resolve) { |key| target.call key }
    end

    def define_each target = dependencies
      define_method(:each) { |&block| target.each(&block) }
    end

    def define_each_key target = dependencies
      define_method(:each_key) { |&block| target.each_key(&block) }
    end

    def define_key? target = dependencies
      define_method(:key?) { |name| target.key? name }
    end

    def define_keys target = dependencies
      define_method(:keys) { target.keys }
    end

    def define_clone
      define_method :clone do
        dup.tap { |duplicate| duplicate.freeze if dependencies.frozen? }
      end
    end

    def define_dup target = self.class,
                   local_register: register.class,
                   local_resolver: resolver.class

      define_method :dup do
        instance = target.new dependencies.dup, register: local_register, resolver: local_resolver
        Module.new.set_temporary_name("containable").extend instance
      end
    end

    def define_freeze
      define_method(:freeze) { dependencies.freeze and self }
    end

    def define_frozen?
      define_method(:frozen?) { dependencies.frozen? }
    end
  end
end
