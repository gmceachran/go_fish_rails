RSpec.describe :play_game, type: :system do
  context "when user clicks the Play Game button" do
    let(:user1) { create_and_log_in }
    let(:user2) { create_and_log_in }
    let(:game) { create :game, max_players: 2 }
    let!(:player1) { create :player, user: user1, game: game }
    let!(:player2) { create :player, user: user2, game: game }

    before do
      visit root_path
      click_on "Play Now"
    end

  it "user is redirected to games#show" do
      expect(page).to have_current_path game_path(game.id)
      expect(page).to have_content "Players"
      expect(page).to have_content "Feed"
      expect(page).to have_content "Your Hand"
      expect(page).to have_content "Books"
    end
  end
end
