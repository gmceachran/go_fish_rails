require "rails_helper"

RSpec.describe GoFish::Card, type: :model do
  describe "#value" do
    let(:card) { GoFish::Card.new(rank: "4", suit: "Spades") }

    it "returns the index of the rank" do
      expect(card.value).to eq 2
    end
  end

  it_behaves_like "a serializable round-trip" do
    subject { GoFish::Card.new(rank: "A", suit: "Spades") }
  end
end
