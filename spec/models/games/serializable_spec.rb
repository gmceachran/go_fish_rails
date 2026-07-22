require "rails_helper"

# Minimal PORO stubs exercising the concern in isolation (not through Card/Deck).
module SerializableSpec
  class Leaf
    include Games::Serializable
    scalar :label
    attr_reader :label
    def initialize(label: nil) = @label = label
  end

  class Container
    include Games::Serializable
    scalar :name
    nested_one :inner, Leaf
    nested_many :items, Leaf
    attr_reader :name, :inner, :items

    def initialize(name: nil, inner: nil, items: [])
      @name = name
      @inner = inner
      @items = items
    end
  end
end

RSpec.describe Games::Serializable, type: :model do
  describe "scalar attributes" do
    let(:container) { SerializableSpec::Container.new(name: "x") }

    it "serializes declared scalars to a string-keyed hash" do
      expect(container.as_json).to include("name" => "x")
    end

    it "rebuilds scalars from json" do
      restored = SerializableSpec::Container.from_json(container.as_json)
      expect(restored.name).to eq "x"
    end
  end

  describe "nested_one" do
    context "when the nested object is present" do
      let(:inner) { SerializableSpec::Leaf.new(label: "a") }
      let(:container) { SerializableSpec::Container.new(inner: inner) }

      it "rebuilds it from json" do
        restored = SerializableSpec::Container.from_json(container.as_json)
        expect(restored.inner.label).to eq "a"
      end
    end

    context "when the nested object is absent" do
      it "maps to nil" do
        restored = SerializableSpec::Container.from_json("name" => "x")
        expect(restored.inner).to be_nil
      end
    end
  end

  describe "nested_many" do
    context "when the collection is present" do
      let(:leaves) do
        [
          SerializableSpec::Leaf.new(label: "a"),
          SerializableSpec::Leaf.new(label: "b")
        ]
      end
      let(:container) { SerializableSpec::Container.new(items: leaves) }

      it "rebuilds each element from json" do
        restored = SerializableSpec::Container.from_json(container.as_json)
        expect(restored.items.map(&:label)).to eq %w[a b]
      end
    end

    context "when the collection is absent" do
      it "maps to an empty array" do
        restored = SerializableSpec::Container.from_json("name" => "x")
        expect(restored.items).to eq []
      end
    end
  end
end
