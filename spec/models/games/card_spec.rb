require "rails_helper"

RSpec.describe Games::Card, type: :model do
  it "has a rank and suit" do
    card = Games::Card.new(rank: "A", suit: "Spades")
    expect(card.rank).to eq "A"
    expect(card.suit).to eq "Spades"
  end

  it "raises InvalidRank for an unknown rank" do
    expect { Games::Card.new(rank: "15", suit: "Spades") }
      .to raise_error Games::Card::InvalidRank
  end

  it "raises InvalidSuit for an unknown suit" do
    expect { Games::Card.new(rank: "10", suit: "Minecraft") }
      .to raise_error Games::Card::InvalidSuit
  end

  describe "#==" do
    context "with the same rank and suit" do
      let(:card) { Games::Card.new(rank: "A", suit: "Spades") }
      let(:matching_card) { Games::Card.new(rank: "A", suit: "Spades") }

      it "is equal" do
        expect(card).to eq matching_card
      end
    end

    context "with a different rank" do
      let(:card) { Games::Card.new(rank: "A", suit: "Spades") }
      let(:different_card) { Games::Card.new(rank: "K", suit: "Spades") }

      it "is not equal" do
        expect(card).not_to eq different_card
      end
    end
  end

  describe "#to_s" do
    it "returns a readable card string" do
      expect(Games::Card.new(rank: "J", suit: "Diamonds").to_s).to eq "Jack of Diamonds"
    end
  end

  it_behaves_like "a serializable round-trip" do
    subject { Games::Card.new(rank: "A", suit: "Spades") }
  end
end
