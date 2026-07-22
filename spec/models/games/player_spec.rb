require "rails_helper"

RSpec.describe Games::Player, type: :model do
  describe "#hand_size" do
    let(:hand) do
      [
        Games::Card.new(rank: "A", suit: "Spades"),
        Games::Card.new(rank: "K", suit: "Hearts")
      ]
    end
    let(:player) { Games::Player.new(user_id: 1, name: "Ana", hand: hand) }

    it "returns the number of cards in the hand" do
      two_cards = 2
      expect(player.hand_size).to be two_cards
    end
  end

  describe ".from_json" do
    let(:player) { Games::Player.new(user_id: 7, name: "Ana") }

    it "preserves user_id and name through a dump/load" do
      restored = Games::Player.from_json(player.as_json)
      expect(restored.user_id).to eq 7
      expect(restored.name).to eq "Ana"
    end
  end

  it_behaves_like "a serializable round-trip" do
    subject { Games::Player.new(user_id: 1, name: "Ana") }
  end
end
