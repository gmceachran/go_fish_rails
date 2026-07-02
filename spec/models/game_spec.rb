require "rails_helper"

RSpec.describe Game, type: :model do
  it "defaults to waiting state" do
    game = create :game

    expect(game).to be_waiting
  end

  it "defaults max_players to 5" do
    game = create :game

    expect(game.max_players).to eq 5
  end
end
