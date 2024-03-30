# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "a container" do
  describe "#extended" do
    it "fails when not extending a module" do
      expectation = proc { Class.new.extend Containable::Vault.new }
      expect(&expectation).to raise_error(TypeError, "Only a module can be a container.")
    end
  end

  describe ".dependencies" do
    it "fails when messaging private method" do
      expectation = proc { container.dependencies }
      expect(&expectation).to raise_error(NoMethodError, /private method/)
    end
  end

  shared_examples "a setter" do |message|
    it "adds value (plain)" do
      container.public_send message, :one, 1
      expect(container["one"]).to eq(1)
    end

    it "registers value (block)" do
      container.public_send(message, :three) { 3 }
      expect(container["three"]).to eq(3)
    end

    it "registers value (function, no arguments)" do
      container.public_send message, :two, proc { 2 }
      expect(container["two"]).to eq(2)
    end

    it "registers value (function, with arguments)" do
      container.public_send message, :two, -> text { text }
      expect(container["two"]).to be_a(Proc)
    end

    it "registers value (callback)" do
      function = proc { 4 }
      container.public_send(message, :four, &function)

      expect(container["four"]).to eq(4)
    end

    it "fails when frozen" do
      container.freeze
      expectation = proc { container.public_send message, :test, :example }

      expect(&expectation).to raise_error(FrozenError, "Can't modify frozen container.")
    end

    it "fails when key exists" do
      container.public_send message, :test, :example
      expectation = proc { container.public_send message, :test, :example }

      expect(&expectation).to raise_error(KeyError, "Dependency is already registered: :test.")
    end
  end

  describe ".[]=" do
    it_behaves_like "a setter", :[]=
  end

  describe ".register" do
    it_behaves_like "a setter", :register

    it "namepaces dependency" do
      container.namespace :one do
        namespace :two do
          register :test, 1
        end
      end

      expect(container["one.two.test"]).to eq(1)
    end
  end

  describe "#namespace" do
    it "registers namespaced dependency" do
      container.namespace :one do
        namespace :two do
          register :three, 3
        end
      end

      expect(container.each.to_h).to eq("one.two.three" => 3)
    end

    it "registers multiple namespaced dependencies" do
      container.namespace :one do
        namespace :two do
          register :three, 3
        end

        namespace :four do
          register :five, 5
        end
      end

      expect(container.each.to_h).to eq("one.two.three" => 3, "one.four.five" => 5)
    end

    it "does nothing without block" do
      container.namespace :one
      expect(container.each.to_h).to eq({})
    end
  end

  shared_examples "a getter" do |message|
    it "resolves value" do
      container[:test] = 1
      expect(container.public_send(message, "test")).to eq(1)
    end

    it "resolves function" do
      container[:test] = proc { 1 }
      expect(container.public_send(message, "test")).to eq(1)
    end

    it "fails with key error when key doesn't exist" do
      expectation = proc { container.public_send message, "test" }
      expect(&expectation).to raise_error(KeyError, %(Unable to resolve dependency: "test".))
    end
  end

  describe ".[]" do
    it_behaves_like "a getter", :[]
  end

  describe ".resolve" do
    it_behaves_like "a getter", :resolve
  end

  describe ".each" do
    it "answers enumerator without block" do
      expect(container.each).to be_a(Enumerator)
    end

    it "answers yields each key and value" do
      container[:one] = 1
      container[:two] = 2
      keys = container.each.reduce("") { |all, (key, value)| "#{all} #{key}: #{value}".strip }

      expect(keys).to eq("one: 1 two: 2")
    end
  end

  describe ".each_key" do
    it "answers enumerator without block" do
      expect(container.each_key).to be_a(Enumerator)
    end

    it "answers yields each key" do
      container[:one] = 1
      container[:two] = 2
      keys = container.each_key.reduce([]) { |all, key| all.append key }

      expect(keys).to eq(%w[one two])
    end
  end

  describe ".key?" do
    it "answers true when found" do
      container["test"] = "one"
      expect(container.key?("test")).to be(true)
    end

    it "answers false when not found" do
      expect(container.key?("test")).to be(false)
    end
  end

  describe ".keys" do
    it "answers keys" do
      container[:one] = 1
      container[:two] = 2

      expect(container.keys).to eq(%w[one two])
    end

    it "answers empty array when keys are not found" do
      expect(container.keys).to eq([])
    end
  end

  describe ".clone" do
    it "sets temporary name" do
      duplicate = container.clone
      expect(duplicate.name).to eq("module:container")
    end

    it "duplicates with unresolved values intact" do
      container.register(:one) { 1 }
      duplicate = container.clone
      container[:one]

      expect(duplicate.each.to_h).to match({"one" => kind_of(Proc)})
    end

    it "remains frozen" do
      container.register(:one) { 1 }
      container.freeze
      duplicate = container.clone

      expect(duplicate.frozen?).to be(true)
    end
  end

  describe ".dup" do
    it "sets temporary name" do
      duplicate = container.clone
      expect(duplicate.name).to eq("module:container")
    end

    it "duplicates with unresolved values intact" do
      container.register(:one) { 1 }
      duplicate = container.dup
      container[:one]

      expect(duplicate.each.to_h).to match({"one" => kind_of(Proc)})
    end

    it "unfreezes" do
      container.register(:one) { 1 }
      container.freeze
      duplicate = container.dup

      expect(duplicate.frozen?).to be(false)
    end
  end

  describe ".freeze" do
    it "freezes container" do
      container.freeze
      expect(container.frozen?).to be(true)
    end

    it "fails when attempting to register new dependencies" do
      container.freeze
      expectation = proc { container.register :two, 1 }

      expect(&expectation).to raise_error(FrozenError, "Can't modify frozen container.")
    end
  end

  describe ".frozen?" do
    it "answers true when frozen" do
      container.freeze
      expect(container.frozen?).to be(true)
    end

    it "answers false when not frozen" do
      expect(container.frozen?).to be(false)
    end
  end
end
