require "rails_helper"

RSpec.describe GoFish::Game, type: :model do
  let(:json) do
    {
      "players" => [
        {
          "user_id" => 0,
          "hand" => [],
          "books" => [],
          "name" => "Lord Farquad"
        },
        {
          "user_id" => 1,
          "hand" => [],
          "books" => [],
          "name" => "Lord Farquad"
        }
      ],
      "active_player_index" => 0,
      "deck" => {
        "cards" => [
          { "rank" => "2", "suit" => "Spades" },
          { "rank" => "3", "suit" => "Spades" }
        ]
      }
    }
  end
  let!(:game) { GoFish::Game.load(json) }

  describe "#load" do
    context "when json is not nil" do
      it "turns the given json string into a ruby object" do
        expect(game).to be_a_kind_of GoFish::Game
        expect(game.players.first.user_id).to be 0
        expect(game.players.last.user_id).to be 1
      end
    end

    context "when json is nil" do
      it "returns nil" do
        expect(GoFish::Game.load(nil)).to be_nil
      end
    end
  end

  describe "#dump" do
    it "turns the given hash into a json string" do
      dumped_object = GoFish::Game.dump(game)
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
end
