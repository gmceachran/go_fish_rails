require "rails_helper"

RSpec.describe CrazyEightsGame, type: :model do
  describe "#start_if_full!" do
    context "when the last player joins" do
      let!(:game) { create :game, max_players: 2, type: "CrazyEightsGame" }
      let!(:player1) { create :player, game: game }
      let!(:player2) { create :player, game: game }
      let(:starting_hand_size) { 7 }
      let(:remaining_deck_size) { 37 }

      def reloaded_state
        CrazyEightsGame.find(game.id).game_state
      end

      def dumped_state
        CrazyEights::Engine.dump(reloaded_state)
      end

      it_behaves_like "a game that starts when full",
        engine_class: CrazyEights::Engine,
        player_class: CrazyEights::Player

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

      it "starts with the first player active" do
        expect(reloaded_state.active_player_index).to eq(0)
      end

      it "persists a drawable deck" do
        deck = reloaded_state.deck
        expect(deck).to be_a(CrazyEights::Deck)
        expect(deck.cards_left).to eq(remaining_deck_size)
      end
    end

    context "when the game is not yet full" do
      let(:game) { create :game, max_players: 2, type: "CrazyEightsGame" }

      before { create(:player, game: game) }

      it_behaves_like "a game that stays waiting until full"
    end
  end
end
