require "rails_helper"

RSpec.describe CrazyEights::Implementation, type: :model do
  let(:json) do
    {
      "players" => [
        {
          "user_id" => 0,
          "hand" => [],
          "name" => "Lord Farquad"
        },
        {
          "user_id" => 1,
          "hand" => [],
          "name" => "Lord Farquad"
        }
      ],
      "active_player_index" => 0,
      "deck" => {
        "cards" => [
          { "rank" => "2", "suit" => "Spades" },
          { "rank" => "3", "suit" => "Spades" }
        ]
      },
      "discard_pile" => [
        { "rank" => "9", "suit" => "Hearts" }
      ],
      "turn_results" => []
    }
  end
  let!(:game) { CrazyEights::Implementation.load(json) }

  describe "#load" do
    context "when json is not nil" do
      it "turns the given json string into a ruby object" do
        expect(game).to be_a_kind_of CrazyEights::Implementation
        expect(game.players.first.user_id).to be 0
        expect(game.players.last.user_id).to be 1
        expect(game.discard_card).to eq CrazyEights::Card.new("9", "Hearts")
      end
    end

    context "when json is nil" do
      it "returns nil" do
        expect(CrazyEights::Implementation.load(nil)).to be_nil
      end
    end
  end

  describe "#dump" do
    it "turns the given hash into a json string" do
      dumped_object = CrazyEights::Implementation.dump(game)
      expect(dumped_object).to eq json
    end
  end

  describe "#active_player?" do
    context "when given user_id does not match active player's user_id" do
      it "returns false" do
        expect(game.active_player?(1)).to be false
      end
    end

    context "when given user_id does match active player's user_id" do
      it "returns true" do
        expect(game.active_player?(0)).to be true
      end
    end
  end

  describe "#player" do
    it "returns the appropriate player by the given id" do
      expect(game.player(0)).to be game.players.first
    end
  end

  describe "#opponents" do
    it "returns the round's opponents" do
      opponents = [ game.players.last ]
      expect(game.opponents).to eq opponents
    end
  end

  describe "#board_for" do
    let(:board) { game.board_for(user_id: 0, game_id: 42) }

    it "builds a game board" do
      expect(board).to be_a(CrazyEights::GameBoard)
      expect(board.game_id).to eq(42)
      expect(board.implementation).to eq("crazy_eights")
    end

    it "includes turn state and player data" do
      expect(board.is_clients_turn).to be(true)
      expect(board.player).to eq(game.players.first)
      expect(board.opponents).to eq([ game.players.last ])
    end

    it "includes crazy eights view settings" do
      expect(board.opponent_partial).to eq("games/opponent")
      expect(board.feed_partial).to eq("games/crazy_eights_feed")
      expect(board.discard_card).to eq(game.discard_card)
    end
  end

  describe "#active_player" do
    let(:active_player) { game.players.first }

    it "returns the active player" do
      expect(game.active_player).to be active_player
    end
  end

  describe "#start" do
    let!(:deck) { CrazyEights::Deck.new }
    let!(:players) { game.players }

    before { game.deck = deck }

    it "shuffles cards" do
      unshuffled_hand = deck.cards[0..6]
      game.start
      shuffled_hand = players.first.hand
      expect(shuffled_hand).not_to eq unshuffled_hand
    end

    context "when there are 1-3 players" do
      it "each player's hand is dealt 7 cards" do
        game.start
        players.each { |player| expect(player.hand_size).to be 7 }
      end
    end

    context "when there are 4-5 players" do
      let(:extra_players) do
        [
          CrazyEights::Player.new(user_id: 2),
          CrazyEights::Player.new(user_id: 3)
        ]
      end

      before do
        game.players += extra_players
      end

      it "each player's hand is dealt 5 cards" do
        game.start
        players.each { |player| expect(player.hand_size).to be 5 }
      end
    end
  end

  describe "#play_turn" do
    context "when the player plays a matching card" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [ { "rank" => "9", "suit" => "Clubs" } ], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "3", "suit" => "Spades" } ], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [] },
          "discard_pile" => [ { "rank" => "9", "suit" => "Hearts" } ],
          "turn_results" => []
        }
      end
      let(:turn) { CrazyEightsTurn.new(rank: "9", suit: "Clubs", user_id: 0) }

      it "moves the card to the discard pile" do
        game.play_turn(turn)
        expect(game.discard_card).to eq CrazyEights::Card.new("9", "Clubs")
        expect(game.players.first.hand).to be_empty
      end

      it "records a result without play_again" do
        result = game.play_turn(turn)
        expect(result.play_again).to be false
      end
    end

    context "when the player plays an eight" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [ { "rank" => "8", "suit" => "Clubs" } ], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "3", "suit" => "Spades" } ], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [] },
          "discard_pile" => [ { "rank" => "9", "suit" => "Hearts" } ],
          "turn_results" => []
        }
      end
      let(:turn) { CrazyEightsTurn.new(rank: "8", suit: "Clubs", user_id: 0) }

      xit "allows the player to choose a new suit" do
        expect()
      end
    end

    context "when the player draws a card" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [ { "rank" => "3", "suit" => "Clubs" } ], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "4", "suit" => "Spades" } ], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [ { "rank" => "9", "suit" => "Spades" } ] },
          "discard_pile" => [ { "rank" => "9", "suit" => "Hearts" } ],
          "turn_results" => []
        }
      end
      let(:turn) { CrazyEightsTurn.new(action: "draw", user_id: 0) }

      it "adds the drawn card to the player's hand" do
        game.play_turn(turn)
        expect(game.players.first.hand).to include CrazyEights::Card.new("9", "Spades")
      end

      it "allows another turn" do
        result = game.play_turn(turn)
        expect(result.play_again).to be true
      end
    end
  end

  describe "#advance_turn" do
    context "when there is a next player" do
      it "moves to the next player" do
        game.advance_turn
        expect(game.active_player_index).to eq 1
      end
    end

    context "when the active player is last" do
      before { game.active_player_index = 1 }

      it "wraps around to the first player" do
        game.advance_turn
        expect(game.active_player_index).to eq 0
      end
    end
  end

  describe "#winner" do
    let(:player) { CrazyEights::Player.new }
    let(:game) { described_class.new }
    before { game.players << player }

    context "when the discard pile is empty (game hasn't started)" do
      it "always returns nil" do
        expect(game.winner).to be_nil
      end
    end

    context "when the discard pile is not empty (game has started)" do
      let(:deck) { game.deck }
      before { game.discard_pile << deck.top_card }

      context "when no player has an empty hand" do
        before { player.hand << CrazyEights::Card.new("A", "Spades") }

        it "returns nil" do
          expect(game.winner).to be_nil
        end
      end

      context "when one player has an empty hand" do
        before do
          player2 = CrazyEights::Player.new
          game.players << player2
          player2.hand << CrazyEights::Card.new("A", "Spades")
        end

        it "returns that player object" do
          expect(game.winner).to be player
        end
      end
    end
  end
end
