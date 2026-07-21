require "rails_helper"

RSpec.describe "Crazy Eights", type: :system do
  let(:user1) { create_and_log_in }
  let!(:game) { create :game, max_players: 2, type: "CrazyEightsGame" }
  let!(:player1) { create :player, user: user1, game: game }
  let(:user2) { create_and_log_in }
  let!(:player2) { create :player, user: user2, game: game }

  before { visit root_path }

  context "when user clicks the Play Game button" do
    it "user is redirected to games#show" do
      click_on "Play Now"

      expect(page).to have_current_path game_path(game.id)
      expect(page).to have_content "Players"
      expect(page).to have_content "Feed"
      expect(page).to have_content "Your Hand"
      expect(page).to have_content "Discard Pile"
    end
  end
end
