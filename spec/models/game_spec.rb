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
      let!(:player1) { create :player, game: game }
      let!(:player2) { create :player, game: game }

      it_behaves_like "a game that starts when full",
        engine_class: GoFish::Engine,
        player_class: GoFish::Player,
        turn_class: Turn,
        turn_params_keys: [ :rank, :opponent ]

      let(:dealt_deck_length) { 38 }
      let(:starting_hand_size) { 7 }

      it "deals a starting hand to each player from the deck" do
        go_fish_game = Game.find(game.id).game_state
        expect(go_fish_game.deck_length).to be dealt_deck_length
        go_fish_game.players.each do |player|
          expect(player.hand_size).to be starting_hand_size
        end
      end
    end

    context "when the game is not yet full" do
      let(:game) { create(:game, max_players: 2) }

      before { create(:player, game: game) }

      it_behaves_like "a game that stays waiting until full"
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

  describe "#declare_winner_if_over!" do
    let(:game) { create(:game, max_players: 2) }
    let!(:player1) { create :player, game: game }
    let!(:player2) { create :player, game: game }

    context "when the game state has a winner" do
      before do
        game.game_state.players.first.hand = []
        game.game_state.players.first.books = [ GoFish::Book.new("3") ]
        game.game_state.players.last.hand = []
        game.save
      end

      it "declares the matching persisted player the winner" do
        game.declare_winner_if_over!

        expect(player1.reload.winner).to be true
        expect(game.reload.state).to eq "over"
        expect(game.ended_at).not_to be_nil
      end
    end

    context "when the game state has no winner" do
      it "leaves the game active" do
        game.declare_winner_if_over!

        expect(game.players.none?(&:winner)).to be true
        expect(game.reload.state).to eq "active"
        expect(game.ended_at).to be_nil
      end
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
  end
end
