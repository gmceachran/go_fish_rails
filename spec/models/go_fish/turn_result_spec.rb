require "rails_helper"

RSpec.describe GoFish::TurnResult, type: :model do
  let(:cards) { [ GoFish::Card.new("9", "Hearts"), GoFish::Card.new("9", "Clubs") ] }

  subject(:turn_result) do
    GoFish::TurnResult.new(go_fish: false,
                            cards: cards,
                            book_made: true,
                            go_again: true,
                            deck_empty: false)
  end

  describe "#initialize" do
    it "defaults to a go_fish turn with no cards" do
      default_result = GoFish::TurnResult.new
      expect(default_result.go_fish).to be false
      expect(default_result.cards).to eq []
    end

    it "sets all attributes when given" do
      expect(turn_result.go_fish).to be false
      expect(turn_result.cards).to eq cards
      expect(turn_result.book_made).to be true
      expect(turn_result.go_again).to be true
      expect(turn_result.deck_empty).to be false
    end
  end

  describe ".from_json" do
    let(:json) do
      {
        "go_fish" => true,
        "cards" => [ { "rank" => "9", "suit" => "Hearts" } ],
        "book_made" => false,
        "go_again" => true,
        "deck_empty" => false
      }
    end

    subject(:result) { GoFish::TurnResult.from_json(json) }

    it "builds a TurnResult from a json hash" do
      expect(result.go_fish).to be true
      expect(result.book_made).to be false
      expect(result.go_again).to be true
      expect(result.deck_empty).to be false
    end

    it "maps cards through Card.from_json" do
      expect(result.cards).to eq [ GoFish::Card.new("9", "Hearts") ]
    end
  end

  describe "#data" do
    it "serializes back to a plain hash with card data" do
      expect(turn_result.data).to eq(
        go_fish: false,
        cards: cards.map(&:data),
        book_made: true,
        go_again: true,
        deck_empty: false
      )
    end
  end
end
