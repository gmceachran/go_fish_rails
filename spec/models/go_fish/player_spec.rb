require "rails_helper"

RSpec.describe GoFish::Player, type: :model do
  let(:player) { described_class.new(user_id: 1) }
  let(:json) { { "user_id" => 0, "hand" => [], "books" => [] } }

  describe "#from_json" do
    it "receives a json hash and returns a player object" do
      player = GoFish::Player.from_json(json)
      expect(player).to be_a_kind_of GoFish::Player
      expect(player.user_id).to be 0
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
