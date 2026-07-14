RSpec.describe :play_game, type: :system do
  let(:user1) { create_and_log_in }
  let(:game) { create :game, max_players: 2 }
  let!(:player1) { create :player, user: user1, game: game }
  let(:user2) { create_and_log_in }
  let!(:player2) { create :player, user: user2, game: game }

  before do
    visit root_path
    override_start game.game_state
  end

  context "when user clicks the Play Game button" do
    it "user is redirected to games#show" do
      click_on "Play Now"

      expect(page).to have_current_path game_path(game.id)
      expect(page).to have_content "Players"
      expect(page).to have_content "Feed"
      expect(page).to have_content "Your Hand"
      expect(page).to have_content "Books"
    end
  end

  describe :take_turn do
    context "when it is not the user's turn" do
      before do
        click_on "Play Now"
      end

      it "the turn form does not appear" do
       expect(page).to have_no_css ".game-actions"
      end
    end

    context "when it is the user's turn" do
      before do
        log_out
        log_in(user1)
        click_on "Play Now"
      end

      it "the turn form is visible" do
        visit game_path(game)
        expect(page).to have_content "Card Rank"
        expect(page).to have_content "Player"
      end

      context "when user presses the turn form submit button" do
        before do
          log_out
          log_in(user1)
          override_start game.game_state
          game.save
          visit game_path(game)
        end

        it "the form disappears" do
          expect(game.game_state.players.first.hand.length).to eq 1
          click_on "Ask for Cards"
          expect(page).to have_no_css ".game-actions"
          expect(page).to have_content "Opponent's Turn"
          expect(game.reload.game_state.players.first.hand.length).to eq 2
        end
      end
    end
  end
end
