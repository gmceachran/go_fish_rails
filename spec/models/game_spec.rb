require "rails_helper"

RSpec.describe Game, type: :model do
  let(:game) { create :game }
  let(:user) { create :user }

  it "defaults to waiting state" do
    expect(game).to be_waiting
  end

  it "defaults max_players to 5" do
    expect(game.max_players).to eq 5
  end

  context "when the game is waiting and has room" do
    it "is joinable" do
      expect(game).to be_joinable
    end
  end

  context "when the game is not waiting" do
    before { game.active! }

    it "is not joinable" do
      expect(game).not_to be_joinable
    end
  end

  context "when the game is full" do
    let(:user) { create :user }

    before do
      game.update!(max_players: 1)
      create :player, game: game, user: user
    end

    it "is not joinable" do
      expect(game).not_to be_joinable
    end
  end
end
