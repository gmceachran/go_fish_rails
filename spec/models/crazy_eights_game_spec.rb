require "rails_helper"

RSpec.describe CrazyEightsGame, type: :model do
  describe "#start_if_full!" do
    context "when the last player joins" do
      let(:game) { create :game, max_players: 2, type: "CrazyEightsGame" }
      let!(:player1) { create :player, game: game }
      let!(:player2) { create :player, game: game }
      let(:starting_hand_size) { 7 }
      let(:remaining_deck_size) { 52 - (starting_hand_size * 2) - 1 }

      def reloaded_state
        CrazyEightsGame.find(game.id).game_state
      end

      def dumped_state
        CrazyEights::Implementation.dump(reloaded_state)
      end

      it "transitions to active and sets started_at" do
        game.reload
        expect(game.state).to eq("active")
        expect(game.started_at).not_to be_nil
      end

      it "reloads a CrazyEights implementation from the database" do
        expect(reloaded_state).to be_a(CrazyEights::Implementation)
      end

      it "persists the deck and discard pile" do
        expect(dumped_state.keys).to include("deck", "discard_pile")
        expect(dumped_state["deck"]["cards"]).not_to be_empty
        expect(dumped_state["discard_pile"]).not_to be_empty
      end

      it "persists dealt hands for each player" do
        dumped_state["players"].each do |player|
          expect(player["hand"].length).to eq(starting_hand_size)
        end
      end

      it "persists turn order and player identities" do
        state = reloaded_state
        expect(state.active_player_index).to eq(0)
        expect(state.players.first.user_id).to eq(player1.user_id)
        expect(state.players.last.user_id).to eq(player2.user_id)
      end

      it "persists a drawable deck" do
        deck = reloaded_state.deck
        expect(deck).to be_a(CrazyEights::Deck)
        expect(deck.cards_left).to eq(remaining_deck_size)
      end

      it "starts with a non-wild discard card" do
        expect(reloaded_state.discard_card).not_to be_wild
      end
    end

    context "when the game is not yet full" do
      let(:game) { create :game, max_players: 2, type: "CrazyEightsGame" }

      before { create(:player, game: game) }

      it "stays waiting without persisting game state" do
        game.reload
        expect(game.state).to eq("waiting")
        expect(game.started_at).to be_nil
        expect(game.game_state).to be_nil
      end
    end
  end
end
