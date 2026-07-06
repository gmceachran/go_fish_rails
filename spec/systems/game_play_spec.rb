RSpec.describe :play_game, type: :system do
  context "when user clicks the Play Game button" do
    let(:user) { create_and_log_in }
    let(:game) { create :game }
    let!(:player) { create :player, user: user, game: game }

    before do
      game.update(max_players: 1)
      visit root_path
      click_on "Play Now"
    end

    it "user is redirected to games#show" do
      expect(page).to have_current_path game_path(game.id)
    end
  end
end
