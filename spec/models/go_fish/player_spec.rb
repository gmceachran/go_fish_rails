require "rails_helper"

RSpec.describe GoFish::Player, type: :model do
  let(:json) { { "user_id" => 0, "hand" => [], "books" => [] } }

  describe "#from_json" do
    it "receives a json hash and returns a player object" do
      player = GoFish::Player.from_json(json)
      expect(player).to be_a_kind_of GoFish::Player
      expect(player.user_id).to be 0
    end
  end
end
