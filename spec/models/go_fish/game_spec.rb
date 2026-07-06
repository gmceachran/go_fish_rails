require "rails_helper"

RSpec.describe GoFish::Game, type: :model do
  let(:game) { described_class.new }
  let(:object) do
    {
      "game_id" => 0,
      "players" => [
        {
          "user_id" => 0,
          "hand" => [],
          "books" => []
        },
        {
          "user_id" => 1,
          "hand" => [],
          "books" => []
        }
      ]
    }
  end
  let(:json) { object.to_json }
  before { 2.times { |i| game.add_player i } }

  describe "#load" do
    it "turns the given json string into a ruby hash" do
      loaded_json = GoFish::Game.load(json)
      expect(loaded_json).to eq object
    end
  end

  describe "#dump" do
    it "turns the given hash into a json string" do
      dumped_object = game.dump
      expect(dumped_object).to eq json
    end
  end

  describe "#add_player" do
    let(:user_id) { 1 }

    it "adds a player object to the game's players array" do
      players = game.players
      expect do
        game.add_player(user_id)
      end.to change { players.length }.by 1
      expect(players.last).to be_a_kind_of GoFish::Player
      expect(players.last.user_id).to be user_id
    end
  end
end
