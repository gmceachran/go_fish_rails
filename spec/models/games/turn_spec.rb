require "rails_helper"

RSpec.describe Games::Turn, type: :model do
  let(:game) { create :game, max_players: 2 }
  let!(:player1) { create :player, game: game }
  let!(:player2) { create :player, game: game }

  let(:game_state) { game.reload.game_state }
  let(:active_player) { game_state.active_player }
  let(:opponent_player) { game_state.opponents.first }

  subject(:turn) { described_class.new(game_id: game.id, user_id: active_player.user_id) }

  it_behaves_like "a turn for an active game and the active player's turn"

  describe "#user_id=" do
    it "matches the active player when the id arrives as a string" do
      subject.user_id = active_player.user_id.to_s
      expect(subject).to be_valid
    end
  end

  describe "#game" do
    it "memoizes the lookup" do
      allow(Game).to receive(:find_by).and_call_original

      first_call = turn.game
      second_call = turn.game

      expect(Game).to have_received(:find_by).once
      expect(first_call).to equal(second_call)
    end
  end
end
