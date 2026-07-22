require "rails_helper"

RSpec.describe GoFish::Deck, type: :model do
  let(:deck) { GoFish::Deck.new }

  it "builds a full deck of GoFish::Cards" do
    expect(deck.cards.size).to eq 52
    expect(deck.cards).to all be_a GoFish::Card
  end

  it "rebuilds GoFish::Cards from json" do
    restored = GoFish::Deck.from_json(deck.as_json)
    expect(restored.cards.first).to be_a GoFish::Card
  end
end
