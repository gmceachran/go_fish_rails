require "rails_helper"

RSpec.describe Player, type: :model do
  let(:user) { create :user }
  let(:game) { create :game }

  context "when the game is waiting and has room" do
    let(:player) { Player.new(game: game, user: user) }

    it "is valid" do
      expect(player).to be_valid
    end
  end

  context "when the game is not waiting" do
    before { game.active! }
    let(:player) { Player.new(game: game, user: user) }

    it "is invalid" do
      expect(player).not_to be_valid
    end
  end

  context "when the game is full" do
    let(:player) { Player.new(game: game, user: create(:user, email_address: "second@example.com")) }
    before do
      game.update!(max_players: 1)
      create :player, game: game, user: create(:user, email_address: "third@example.com")
    end

    it "is invalid" do
      expect(player).not_to be_valid
    end
  end

  context "when the user already joined the game" do
    before { create :player, game: game, user: user }

    it "is invalid" do
      player = Player.new(game: game, user: user)
      expect(player).not_to be_valid
    end
  end
end
