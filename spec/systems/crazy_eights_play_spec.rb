require "rails_helper"

RSpec.describe :play_crazy_eights, type: :system do
  let(:user1) { create_and_log_in }
  let(:game) { create :game, max_players: 2, type: "CrazyEightsGame" }
  let!(:player1) { create :player, user: user1, game: game }
  let(:user2) { create_and_log_in }
  let!(:player2) { create :player, user: user2, game: game }

  before do
    visit root_path
    override_start game.game_state
    click_on "Play Now"
  end

  describe :take_turn do
    context "when it is not the user's turn" do
      it "the turn form does not appear" do
       expect(page).to have_no_css ".game-actions"
      end
    end

    context "when it is the user's turn" do
      before do
        log_out
        log_in(user1)
        # click_on "Play Now"
      end

      it "the turn form is visible" do
        visit game_path(game)
        expect(page).to have_content "Draw Card"
      end

      # context "when the user does not have a playable card" do

      # end

      context "when the user draws a card" do
        before { visit game_path(game) }

        it "the turn does not advance" do
          click_on "Draw Card"
          expect(page).to have_content "Your Turn"
        end
      end
    end
  end

  context "when the turn empties the last hand" do
    before do
      log_out
      log_in(user1)
      override_crazy_eights_win game.game_state
      game.save
      visit game_path(game)
    end

    it "a completed game shows the winner" do
      click_on "5 of Spades"

      expect(page).to have_content "#{user1.email_address} wins!"
      expect(page).to have_content user2.email_address
      expect(page).to have_content "Turns played: 1"
      expect(page).to have_content "less than a minute"
    end
  end
end
