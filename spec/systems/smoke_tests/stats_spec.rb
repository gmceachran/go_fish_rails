require "rails_helper"

RSpec.describe "Stats", type: :system do
  let!(:user) { create_and_log_in }
  let(:opponent) { create(:user, email_address: "opponent@example.com") }

  context "when the user has won one game and lost another" do
    before do
      won_game = create(:game, max_players: 2)
      create(:player, game: won_game, user: opponent)
      winning_player = create(:player, game: won_game, user: user)
      won_game.declare_winner!(winning_player)

      lost_game = create(:game, max_players: 2)
      losing_player = create(:player, game: lost_game, user: user)
      create(:player, game: lost_game, user: opponent)
      opponent_player = lost_game.players.find_by(user: opponent)
      lost_game.declare_winner!(opponent_player)

      visit stats_path
    end

    it "shows correct games played, won, and win percentage" do
      games_played = "2"
      games_won = "1"

      expect(page).to have_content games_played
      expect(page).to have_content games_won
      expect(page).to have_content("50.0%")
    end
  end
end
