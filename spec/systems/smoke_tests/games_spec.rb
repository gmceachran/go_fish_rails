require "rails_helper"


RSpec.describe "Games", type: :system do
  describe "#index" do
    it "shows the game index" do
      create_and_log_in
      visit games_path

      expect(page).to have_content "Your Games"
      expect(page).to have_content "All Games"
    end
  end


  describe "#history" do
    let(:user) { create_and_log_in }
    let(:opponent) { create :user, email_address: "opponent@example.com" }
    let(:game) { create :game, max_players: 2 }

    context "when the user has a completed game they won" do
      before do
        create :player, game: game, user: opponent
        player = create :player, game: game, user: user
        game.declare_winner!(player)
        visit games_history_path
      end

      it "shows the game with a won outcome" do
        expect(page).to have_content("Game #{game.id}")
        expect(page).to have_content("Won")
      end
    end

    context "when the user has a completed game they lost" do
      before do
        player = create(:player, game: game, user: opponent)
        create(:player, game: game, user: user)
        game.declare_winner!(player)
        visit games_history_path
      end

      it "shows the game with a lost outcome" do
        expect(page).to have_content("Game #{game.id}")
        expect(page).to have_content("Lost")
      end
    end
  end
end
