require "rails_helper"

RSpec.describe Game, type: :model do
  let(:game) { create :game }
  let(:user) { create :user }

  it "defaults to waiting state" do
    expect(game).to be_waiting
  end

  it "defaults max_players to 5" do
    expect(game.max_players).to eq 5
  end

  context "when the game is waiting and has room" do
    it "is joinable" do
      expect(game).to be_joinable
    end
  end

  context "when the game is not waiting" do
    before do
      game.update!(max_players: 1)
      create(:player, game: game)
    end

    it "is not joinable" do
      expect(game).not_to be_joinable
    end
  end

  context "when the game is full" do
    let(:user) { create :user }

    before do
      game.update!(max_players: 1)
      create :player, game: game, user: user
    end

    it "is not joinable" do
      expect(game).not_to be_joinable
    end
  end

  describe "#start_if_full!" do
    context "when the last player joins" do
      let(:game) { create(:game, max_players: 2) }

      before do
        create(:player, game: game)
        create(:player, game: game)
      end

      it "transitions to active and sets started_at" do
        game.reload
        expect(game.state).to eq("active")
        expect(game.started_at).not_to be_nil
      end
    end

    context "when the game is not yet full" do
      let(:game) { create(:game, max_players: 2) }

      before { create(:player, game: game) }

      it "stays waiting" do
        game.reload
        expect(game.state).to eq("waiting")
        expect(game.started_at).to be_nil
      end
    end
  end

  describe "#declare_winner!" do
    let(:game) { create(:game, max_players: 1) }
    let!(:winner) { create(:player, game: game) }

    it "marks the given player as winner" do
      game.declare_winner!(winner)

      expect(winner.reload.winner).to be true
      expect(game.reload.state).to eq "over"
      expect(game.ended_at).not_to be_nil
    end
  end

  describe :game_state do
    context "when game is not full" do
      let(:game) { create :game }

      it "game is waiting" do
        waiting = "waiting"
        expect(game.state).to eq waiting
      end

      it "game cannot be active" do
        active = 1
        game.update(state: active)
        expect(game).to be_invalid
      end
    end

    context "when game is full" do
      let(:game) { create :game }

      it "game is active" do
        # expect(game) started at to not be nill
        # expect game state to be active
      end

      it "game cannot be waiting" do
        
      end
    end

    context "when there is no winner" do
      it "game is active" do
        
      end

      it "game cannot be over" do
        
      end
    end

    context "when there is a winner" do
      it "game is over" do
        
      end

      it "game cannot be active" do
        
      end

    end
  end
end
