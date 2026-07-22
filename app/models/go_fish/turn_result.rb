module GoFish
  class TurnResult
    include Games::Serializable
    scalar :go_fish, :book_made, :go_again, :deck_empty
    nested_many :cards, GoFish::Card

    attr_accessor :cards, :book_made, :go_again, :deck_empty
    attr_reader :go_fish

    def initialize(go_fish: false, cards: [], book_made: false, go_again: false, deck_empty: false)
      @go_fish = go_fish
      @cards = cards
      @book_made = book_made
      @go_again = go_again
      @deck_empty = deck_empty
    end
  end
end
