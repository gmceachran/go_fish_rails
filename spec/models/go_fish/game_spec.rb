require "rails_helper"

RSpec.describe GoFish::Game, type: :model do
  let(:game) { described_class.new }
  let(:object) { { "game_id" => 1 } }
  let(:json) { object.to_json }

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
end
