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

  it "is valid with valid attributes" do
    expect(turn).to be_valid
  end

  describe "presence" do
    it "requires a rank" do
      turn.rank = nil
      expect(turn).not_to be_valid
    end

    it "requires an opponent" do
      turn.opponent = nil
      expect(turn).not_to be_valid
    end

    it "requires a game_id" do
      turn.game_id = nil
      expect(turn).not_to be_valid
    end

    it "requires a user_id" do
      turn.user_id = nil
      expect(turn).not_to be_valid
    end
  end

  describe "rank inclusion" do
    let(:invalid_rank) { "11" }

    it "rejects a rank not in GoFish::Card::RANKS" do
      turn.rank = invalid_rank
      expect(turn).not_to be_valid
    end
  end

  describe "game state" do
    context "when the game does not exist" do
      let(:nonexistent_game_id) { -1 }

      it "is invalid" do
        turn.game_id = nonexistent_game_id
        expect(turn).not_to be_valid
      end
    end

    context "when the game is not active" do
      let(:waiting_game) { create :game, max_players: 2 }

      it "is invalid" do
        turn.game_id = waiting_game.id
        expect(turn).not_to be_valid
      end
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
  end

  describe "turn order" do
    it "rejects a user who is not the active player" do
      turn.user_id = opponent_player.user_id
      expect(turn).not_to be_valid
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
