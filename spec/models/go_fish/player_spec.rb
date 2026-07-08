require "rails_helper"

RSpec.describe GoFish::Player, type: :model do
  let(:player) { described_class.new(user_id: 1) }
  let(:json) do
    {
      "user_id" => 0,
      "hand" => [],
      "books" => [ { "rank" => rank } ]
    }
  end

  describe "#from_json" do
    let(:rank) { "4" }

    it "receives a json hash and returns a player object" do
      player = GoFish::Player.from_json(json)
      expect(player).to be_a_kind_of GoFish::Player
      expect(player.user_id).to be 0
    end

    it "maps books into GoFish::Book objects" do
      player = GoFish::Player.from_json(json)
      expect(player.books.first).to be_a_kind_of GoFish::Book
      expect(player.books.first.rank).to eq rank
    end
  end

  describe '#hand_size' do
    before { player.hand << GoFish::Card.new('A', 'Spades') }

    it "returns the length of player's hand" do
      one_card = 1
      expect(player.hand_size).to be one_card
    end
  end
end
