require "rails_helper"

RSpec.describe GoFish::Game, type: :model do
  let(:json) do
    {
      "players" => [
        {
          "user_id" => 0,
          "hand" => [],
          "books" => [],
          "name" => "Lord Farquad"
        },
        {
          "user_id" => 1,
          "hand" => [],
          "books" => [],
          "name" => "Lord Farquad"
        }
      ],
      "active_player_index" => 0
    }
  end
  let!(:game) { GoFish::Game.load(json) }

  describe "#load" do
    context "when json is not nil" do
      it "turns the given json string into a ruby object" do
        expect(game).to be_a_kind_of GoFish::Game
        expect(game.players.first.user_id).to be 0
        expect(game.players.last.user_id).to be 1
      end
    end

    context "when json is nil" do
      it "returns nil" do
        expect(GoFish::Game.load(nil)).to be_nil
      end
    end
  end

  describe "#dump" do
    it "turns the given hash into a json string" do
      dumped_object = GoFish::Game.dump(game)
      expect(dumped_object).to eq json
    end
  end

  describe "#active_player?" do
    context "when given user_id does not match active player's user_id" do
      it "returns false" do
        expect(game.active_player?(1)).to be false
      end
    end

    context "when given user_id does match active player's user_id" do
      it "returns true" do
        expect(game.active_player?(0)).to be true
      end
    end
  end

  describe "#opponents" do
    it "returns the round's opponents" do
      opponents = [game.players.last]
      expect(game.opponents).to eq opponents
    end
  end

  describe "#active_player" do
    let(:active_player) { game.players.first }
    it "returns the active player" do
      expect(game.active_player).to be active_player
    end
  end
end
