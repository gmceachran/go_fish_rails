require "rails_helper"

RSpec.describe :play_go_fish, type: :system do
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

      context "when the opponent holds the requested rank" do
        before do
          log_out
          log_in(user1)
          override_go_fish_match(game.game_state)
          game.save
          visit game_path(game)
        end

        it "the turn does not advance" do
          click_on "Ask for Cards"
          expect(page).to have_css ".game-actions"
          expect(page).to have_content "Your Turn"
        end
      end

      context "when the user does not press the form submit button within 30 seconds" do
        let(:wait_time) { 0.1 }
        before do
          log_out
          log_in(user1)
          override_start game.game_state
          game.save
        end

        xit "submits a response automatically", :js do
          GoFish::GameBoard.time_duration = wait_time
          visit game_path(game)

          expect(page).to have_css ".game-actions"
          expect(page).to have_content "Your Turn"

          expect(page).to have_no_css ".game-actions"
          expect(page).to have_content "Opponent's Turn"
        end
      end
    end
  end

  context "when the turn empties the last hand" do
    before do
      log_out
      log_in(user1)
      override_go_fish_win game.game_state
      game.save
      visit game_path(game)
    end

    it "a completed game shows the winner" do
      click_on "Ask for Cards"

      expect(page).to have_content "#{user1.email_address} wins!"
      expect(page).to have_content user2.email_address
      expect(page).to have_content "Turns played: 1"
      expect(page).to have_content "Books made: 1"
      expect(page).to have_content "less than a minute"
    end
  end
end
