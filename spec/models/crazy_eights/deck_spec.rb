require "rails_helper"

RSpec.describe CrazyEights::Deck, type: :model do
  let(:deck) { CrazyEights::Deck.new }

  it "builds a full deck of CrazyEights::Cards" do
    expect(deck.cards.size).to eq 52
    expect(deck.cards).to all be_a CrazyEights::Card
  end

  it "rebuilds CrazyEights::Cards from json" do
    restored = CrazyEights::Deck.from_json(deck.as_json)
    expect(restored.cards.first).to be_a CrazyEights::Card
  end
end
