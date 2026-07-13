require "rails_helper"

RSpec.describe CrazyEights::Player, type: :model do
  let(:player) { CrazyEights::Player.new(user_id: 1, hand: [ CrazyEights::Card.new("9", "Hearts") ]) }

  describe "#hand_size" do
    it "returns the number of cards in the hand" do
      expect(player.hand_size).to eq 1
    end
  end

  describe ".from_json" do
    let(:json) do
      {
        "user_id" => 2,
        "hand" => [ { "rank" => "K", "suit" => "Diamonds" } ],
        "name" => "Player Two"
      }
    end

    it "builds a player from json" do
      loaded_player = described_class.from_json(json)
      expect(loaded_player.user_id).to eq(2)
      expect(loaded_player.name).to eq("Player Two")
    end

    it "loads the player's hand" do
      loaded_player = described_class.from_json(json)
      expect(loaded_player.hand).to eq([ CrazyEights::Card.new("K", "Diamonds") ])
    end
  end
end
