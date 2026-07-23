require "rails_helper"

RSpec.describe Turn, type: :model do
  let(:game) { create :game, max_players: 2 }
  let!(:player1) { create :player, game: game }
  let!(:player2) { create :player, game: game }

  let(:go_fish_game) { game.reload.game_state }
  let(:active_player) { go_fish_game.active_player }
  let(:opponent_player) { go_fish_game.opponents.first }
  let(:held_rank) { active_player.hand.first.rank }

  let(:valid_attributes) do
    {
      rank: held_rank,
      opponent: opponent_player.user_id,
      game_id: game.id,
      user_id: active_player.user_id
    }
  end

  subject(:turn) { described_class.new(valid_attributes) }

  it_behaves_like "a turn for an active game and the active player's turn"

  describe "rank inclusion" do
    let(:invalid_rank) { "11" }

    it "rejects a rank not in GoFish::Card::RANKS" do
      turn.rank = invalid_rank
      expect(turn).not_to be_valid
    end
  end

  describe "opponent validity" do
    let(:outside_user) { create :user }

    it "rejects an opponent not in the game" do
      turn.opponent = outside_user.id
      expect(turn).not_to be_valid
    end

    it "rejects the asking player as their own opponent" do
      turn.opponent = turn.user_id
      expect(turn).not_to be_valid
    end

    it "requires an opponent" do
      turn.opponent = nil
      expect(turn).not_to be_valid
    end

    it "is valid when opponent arrives as a string" do
      turn.opponent = opponent_player.user_id.to_s
      expect(turn).to be_valid
    end
  end

  describe "hand possession" do
    let(:unheld_rank) do
      GoFish::Card::RANKS.find { |r| active_player.hand.none? { |c| c.rank == r } }
    end

    it "rejects a rank the asking player does not hold" do
      turn.rank = unheld_rank
      expect(turn).not_to be_valid
    end
  end
end
