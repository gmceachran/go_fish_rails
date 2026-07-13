module GoFish
  class TurnResult
    attr_accessor :cards, :book_made, :go_again, :deck_empty
    attr_reader :go_fish

    def initialize(go_fish: false,
                    cards: [],
                    book_made: false,
                    go_again: false,
                    deck_empty: false)
      @go_fish = go_fish
      @cards = cards
      @book_made = book_made
      @go_again = go_again
      @deck_empty = deck_empty
    end

    def self.from_json(json)
      cards = json["cards"].map { |card| GoFish::Card.from_json(card) }

      TurnResult.new(go_fish: json["go_fish"],
                     cards: cards,
                     book_made: json["book_made"],
                     go_again: json["go_again"],
                     deck_empty: json["deck_empty"])
    end

    def data
      {
        go_fish: go_fish,
        cards: cards.map(&:data),
        book_made: book_made,
        go_again: go_again,
        deck_empty: deck_empty
      }
    end
  end
end
