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
        sleep 0.1
        log_in(user1)
        sleep 0.1
        # click_on "Play Now"
      end

      it "the turn form is visible" do
        visit game_path(game)
        expect(page).to have_content "Draw Card"
      end

      # context "when the user has a playable card and clicks on it" do
      #   before do
      #     log_out
      #     log_in(user1)
      #     override_start game.game_state
      #     game.save
      #     visit game_path(game)
      #   end

      #   it "the turn ends" do
      #     expect(game.game_state.players.first.hand.length).to eq 1
      #     click_on "Ask for Cards"
      #     expect(page).to have_no_css ".game-actions"
      #     expect(page).to have_content "Opponent's Turn"
      #     expect(game.reload.game_state.players.first.hand.length).to eq 2
      #   end
      # end

      # context "when the user does not have a playable card" do

      # end
    end
  end
end
