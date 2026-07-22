require "rails_helper"

RSpec.describe CrazyEightsTurn, type: :model do
  let(:game) { create :game, type: "CrazyEightsGame", max_players: 2 }
  let!(:player1) { create :player, game: game }
  let!(:player2) { create :player, game: game }

  let(:game_state) { game.reload.game_state }
  let(:active_player) { game_state.active_player }
  let(:opponent_player) { game_state.opponents.first }

  # game_state is a JSONB-serialized PORO, not an association — CrazyEightsTurn
  # loads its own independent copy from the DB (via Game.find_by), so any
  # in-memory mutation made here must be persisted back before it's visible to
  # `turn`. A fresh `Game.find` + explicit attribute assignment is used
  # (instead of `game.save!`) because Rails swaps in a newly-deserialized
  # game_state after the first save, silently decoupling this example's
  # `game_state` object from what a second in-place mutation would need to
  # reach — reassigning through a new instance sidesteps that entirely.
  def persist_game_state!
    Game.find(game.id).update!(game_state: game_state)
  end

  # Deterministic: use a held card that already matches the discard pile's
  # rank/suit/wild, forcing the discard pile's top card to match otherwise, so
  # "valid attributes" never flakes on the random deal.
  let(:matching_card) do
    found = active_player.hand.find do |c|
      c.wild? || c.rank == game_state.discard_card.rank || c.suit == game_state.discard_card.suit
    end
    next found if found

    fallback = active_player.hand.first
    game_state.discard_pile << CrazyEights::Card.new(rank: fallback.rank, suit: fallback.suit)
    persist_game_state!
    fallback
  end

  let(:valid_attributes) do
    {
      rank: matching_card.rank,
      suit: matching_card.suit,
      game_id: game.id,
      user_id: active_player.user_id
    }
  end

  subject(:turn) { described_class.new(valid_attributes) }

  it_behaves_like "a turn for an active game and the active player's turn"

  describe "#draw?" do
    it "is true when the action is draw" do
      turn.action = "draw"
      expect(turn.draw?).to be true
    end

    it "is false for any other action" do
      turn.action = "play"
      expect(turn.draw?).to be false
    end
  end

  describe "draw validation" do
    it "rejects a draw when the deck is empty" do
      turn.action = "draw"
      game_state.deck.cards.clear
      persist_game_state!

      expect(turn).not_to be_valid
      expect(turn.errors[:action]).to be_present
    end
  end

  describe "card fields" do
    it "requires a rank when playing a card" do
      turn.rank = nil
      expect(turn).not_to be_valid
    end

    it "requires a suit when playing a card" do
      turn.suit = nil
      expect(turn).not_to be_valid
    end

    it "rejects a rank outside CrazyEights::Card::RANKS" do
      turn.rank = "11"
      expect(turn).not_to be_valid
    end

    it "rejects a suit outside CrazyEights::Card::SUITS" do
      turn.suit = "Minecraft"
      expect(turn).not_to be_valid
    end
  end

  describe "card possession" do
    let(:unheld_rank_and_suit) do
      CrazyEights::Card::SUITS.each do |suit|
        CrazyEights::Card::RANKS.each do |rank|
          held = active_player.hand.any? { |c| c.rank == rank && c.suit == suit }
          return [ rank, suit ] unless held
        end
      end
    end

    it "rejects a card the asking player does not hold" do
      rank, suit = unheld_rank_and_suit
      turn.rank = rank
      turn.suit = suit

      expect(turn).not_to be_valid
    end
  end

  describe "discard match" do
    context "with a wild card" do
      let(:wild_card) { CrazyEights::Card.new(rank: CrazyEights::Card::WILD_RANK, suit: "Spades") }

      it "is accepted regardless of the discard pile" do
        active_player.hand << wild_card
        persist_game_state!
        turn.rank = wild_card.rank
        turn.suit = wild_card.suit

        expect(turn).to be_valid
      end
    end

    context "with a card matching neither the discard pile's rank nor suit" do
      let(:mismatched_card) { active_player.hand.find { |c| !c.wild? } }

      let(:mismatched_discard_card) do
        other_rank = (CrazyEights::Card::RANKS - [ mismatched_card.rank, CrazyEights::Card::WILD_RANK ]).first
        other_suit = (CrazyEights::Card::SUITS - [ mismatched_card.suit ]).first
        CrazyEights::Card.new(rank: other_rank, suit: other_suit)
      end

      it "is rejected" do
        game_state.discard_pile << mismatched_discard_card
        persist_game_state!
        turn.rank = mismatched_card.rank
        turn.suit = mismatched_card.suit

        expect(turn).not_to be_valid
      end
    end
  end
end
