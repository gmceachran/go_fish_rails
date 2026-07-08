require "rails_helper"

RSpec.describe GoFish::Player, type: :model do
  let(:player) { described_class.new(user_id: 1) }
  let(:json) do
    {
      "user_id" => 0,
      "hand" => [],
      "books" => [ { "rank" => rank } ]
    }
  end

  describe "#from_json" do
    let(:rank) { "4" }

    it "receives a json hash and returns a player object" do
      player = GoFish::Player.from_json(json)
      expect(player).to be_a_kind_of GoFish::Player
      expect(player.user_id).to be 0
    end

    it "maps books into GoFish::Book objects" do
      player = GoFish::Player.from_json(json)
      expect(player.books.first).to be_a_kind_of GoFish::Book
      expect(player.books.first.rank).to eq rank
    end
  end

  describe '#hand_size' do
    before { player.hand << GoFish::Card.new('A', 'Spades') }

    it "returns the length of player's hand" do
      one_card = 1
      expect(player.hand_size).to be one_card
    end
  end

  describe "#cards_of_rank_given" do
    let(:matching_card) { GoFish::Card.new("4", "Spades") }
    let(:other_card) { GoFish::Card.new("7", "Hearts") }

    before { player.hand = [ matching_card, other_card ] }

    context "when hand contains cards of the given rank" do
      it "removes and returns those cards" do
        result = player.cards_of_rank_given("4")
        expect(result).to eq [ matching_card ]
        expect(player.hand).to eq [ other_card ]
      end
    end

    context "when hand contains no cards of the given rank" do
      it "returns an empty array and leaves hand unchanged" do
        result = player.cards_of_rank_given("9")
        expect(result).to eq []
        expect(player.hand).to eq [ matching_card, other_card ]
      end
    end
  end

  describe "#create_book_if_possible" do
    let(:rank) { "4" }
    let(:matching_cards) do
      [
        GoFish::Card.new(rank, "Spades"),
        GoFish::Card.new(rank, "Clubs"),
        GoFish::Card.new(rank, "Hearts"),
        GoFish::Card.new(rank, "Diamonds")
      ]
    end
    let(:other_card) { GoFish::Card.new("7", "Hearts") }

    context "when hand contains four cards of the same rank" do
      before { player.hand = matching_cards + [ other_card ] }

      it "creates a book and removes the cards from hand" do
        result = player.create_book_if_possible
        expect(result).to be true
        expect(player.books.first).to be_a_kind_of GoFish::Book
        expect(player.books.first.rank).to eq rank
        expect(player.hand).to eq [ other_card ]
      end
    end

    context "when hand contains no four-of-a-kind" do
      before { player.hand = [ other_card ] }

      it "returns false and leaves hand unchanged" do
        result = player.create_book_if_possible
        expect(result).to be false
        expect(player.books).to be_empty
        expect(player.hand).to eq [ other_card ]
      end
    end
  end
end
