require "rails_helper"

RSpec.describe GoFish::TurnResult, type: :model do
  let(:cards) do
    [
      GoFish::Card.new(rank: "9", suit: "Hearts"),
      GoFish::Card.new(rank: "9", suit: "Clubs")
    ]
  end

  subject(:turn_result) do
    GoFish::TurnResult.new(go_fish: false,
                           cards: cards,
                           book_made: true,
                           go_again: true,
                           deck_empty: false)
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

    it "builds a TurnResult with cards mapped through Card" do
      result = GoFish::TurnResult.from_json(json)
      expect(result.go_fish).to be true
      expect(result.cards).to eq [ GoFish::Card.new(rank: "9", suit: "Hearts") ]
    end
  end

  it_behaves_like "a serializable round-trip"
end
