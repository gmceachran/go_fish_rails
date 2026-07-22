require "rails_helper"

RSpec.describe CrazyEights::Player, type: :model do
  it_behaves_like "a serializable round-trip" do
    subject do
      CrazyEights::Player.new(
        user_id: 2,
        name: "Player Two",
        hand: [ CrazyEights::Card.new(rank: "9", suit: "Hearts") ]
      )
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

    it "rebuilds hand as CrazyEights::Card objects" do
      player = CrazyEights::Player.from_json(json)
      expect(player.hand).to eq([ CrazyEights::Card.new(rank: "K", suit: "Diamonds") ])
    end
  end
end
