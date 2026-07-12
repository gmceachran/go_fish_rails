require "rails_helper"

RSpec.describe GoFish::Implementation, type: :model do
  let(:json) do
    {
      "players" => [
        {
          "user_id" => 0,
          "hand" => [],
          "books" => [],
          "name" => "Lord Farquad",
          "cant_play" => false
        },
        {
          "user_id" => 1,
          "hand" => [],
          "books" => [],
          "name" => "Lord Farquad",
          "cant_play" => false
        }
      ],
      "active_player_index" => 0,
      "deck" => {
        "cards" => [
          { "rank" => "2", "suit" => "Spades" },
          { "rank" => "3", "suit" => "Spades" }
        ]
      },
      "turn_results" => []
    }
  end
  let!(:game) { GoFish::Implementation.load(json) }

  describe "#load" do
    context "when json is not nil" do
      it "turns the given json string into a ruby object" do
        expect(game).to be_a_kind_of GoFish::Implementation
        expect(game.players.first.user_id).to be 0
        expect(game.players.last.user_id).to be 1
      end
    end

    context "when json is nil" do
      it "returns nil" do
        expect(GoFish::Implementation.load(nil)).to be_nil
      end
    end
  end

  describe "#dump" do
    it "turns the given hash into a json string" do
      dumped_object = GoFish::Implementation.dump(game)
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

  describe "#active_player" do
    let(:active_player) { game.players.first }
    it "returns the active player" do
      expect(game.active_player).to be active_player
    end
  end

  describe '#start' do
    let(:deck) { GoFish::Deck.new }
    let(:players) { game.players }

    it 'shuffles cards' do
      unshuffled_hand = deck.cards[0..6]
      game.start
      shuffled_hand = players.first.hand
      expect(shuffled_hand).not_to eq unshuffled_hand
    end

    context 'when there are 2-3 players' do
      it "each player's is dealt 7 cards" do
        game.start
        players.each { |player| expect(player.hand_size).to be 7 }
      end
    end

    context 'when there are 4-5 players' do
      let(:extra_players) do
        [
          GoFish::Player.new(user_id: 2),
          GoFish::Player.new(user_id: 3)
        ]
      end
      before { game.players += extra_players }

      it "each player's is dealt 5 cards" do
        game.start
        players.each { |player| expect(player.hand_size).to be 5 }
      end
    end
  end

 describe "#deck_length" do
    let(:deck_size) { 2 }

    it "returns the number of cards in the deck" do
      expect(game.deck_length).to be deck_size
    end
  end

  describe "#play_turn" do
    context "when the opponent holds the requested rank" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [ { "rank" => "9", "suit" => "Hearts" } ], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "9", "suit" => "Clubs" } ], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [] },
          "turn_results" => []
        }
      end
      let(:turn) { Turn.new(rank: "9", opponent: 1, user_id: 0) }

      it "transfers the cards to the asking player" do
        game.play_turn(turn)
        expect(game.players.first.hand).to include GoFish::Card.new("9", "Clubs")
      end

      it "records a non-go_fish result with go_again true" do
        result = game.play_turn(turn)
        expect(result.go_fish).to be false
        expect(result.go_again).to be true
      end
    end

    context "when the opponent does not hold the requested rank" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [ { "rank" => "9", "suit" => "Hearts" } ], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "3", "suit" => "Clubs" } ], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [ { "rank" => "9", "suit" => "Spades" } ] },
          "turn_results" => []
        }
      end
      let(:turn) { Turn.new(rank: "9", opponent: 1, user_id: 0) }

      it "draws from the deck" do
        game.play_turn(turn)
        expect(game.players.first.hand).to include GoFish::Card.new("9", "Spades")
      end

      it "sets go_again true when the drawn card matches the rank" do
        result = game.play_turn(turn)
        expect(result.go_fish).to be true
        expect(result.go_again).to be true
      end
    end

    context "when the drawn card does not match the requested rank" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [ { "rank" => "9", "suit" => "Hearts" } ], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "3", "suit" => "Clubs" } ], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [ { "rank" => "4", "suit" => "Spades" } ] },
          "turn_results" => []
        }
      end
      let(:turn) { Turn.new(rank: "9", opponent: 1, user_id: 0) }

      it "sets go_again false" do
        result = game.play_turn(turn)
        expect(result.go_again).to be false
      end
    end

    context "when the asking player completes a book" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0,
              "hand" => [
                { "rank" => "9", "suit" => "Hearts" },
                { "rank" => "9", "suit" => "Spades" },
                { "rank" => "9", "suit" => "Diamonds" }
              ],
              "books" => [],
              "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [ { "rank" => "9", "suit" => "Clubs" } ], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [] },
          "turn_results" => []
        }
      end
      let(:turn) { Turn.new(rank: "9", opponent: 1, user_id: 0) }

      it "moves the four cards into a book" do
        game.play_turn(turn)
        expect(game.players.first.books.map(&:rank)).to include "9"
        expect(game.players.first.hand).to be_empty
      end
    end

    context "when the asking player's hand is empty after the turn and the deck has cards" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [ { "rank" => "2", "suit" => "Clubs" } ] },
          "turn_results" => []
        }
      end
      let(:turn) { Turn.new(rank: "9", opponent: 1, user_id: 0) }

      it "deals a replacement card" do
        game.play_turn(turn)
        expect(game.players.first.hand).not_to be_empty
      end
    end

    context "when the asking player's hand and the deck are both empty" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [] },
          "turn_results" => []
        }
      end
      let(:turn) { Turn.new(rank: "9", opponent: 1, user_id: 0) }

      it "marks the player as cant_play" do
        game.play_turn(turn)
        expect(game.players.first.cant_play).to be true
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

    context "when the next player cant_play" do
      let(:json) do
        {
          "players" => [
            { "user_id" => 0, "hand" => [], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 1, "hand" => [], "books" => [], "name" => "Lord Farquad" },
            { "user_id" => 2, "hand" => [], "books" => [], "name" => "Lord Farquad" }
          ],
          "active_player_index" => 0,
          "deck" => { "cards" => [] },
          "turn_results" => []
        }
      end

      before { game.players[1].cant_play = true }

      it "skips them" do
        game.advance_turn
        expect(game.active_player_index).to eq 2
      end
    end
  end

  describe '#winner' do
    context 'when one or more player has cards' do
      before { game.players.first.hand = [ GoFish::Card.new('A', 'Spades') ] }

      it 'winner returns nil' do
        expect(game.winner).to be_nil
      end
    end

    context 'when no player has cards' do
      let(:winner) { game.players.first }

      context 'when one player has more books than the others' do
        before do
          game.players.first.books.push GoFish::Book.new('3'), GoFish::Book.new('4')
          game.players.last.books.push GoFish::Book.new('5')
        end

        it 'winner returns that player name' do
          expect(game.winner).to eq winner
        end
      end


      context 'when the two players with the most books have the same amount' do
        before do
          game.players.first.books.push GoFish::Book.new('K')
          game.players.last.books.push GoFish::Book.new('Q')
        end

        it 'winner returns the id of the player with the highest rank' do
          expect(game.winner).to eq winner
        end
      end
    end
  end
end
