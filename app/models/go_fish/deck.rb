require_relative "card"

module GoFish
  class Deck
    attr_accessor :cards

    def initialize(cards = Card::SUITS.flat_map do |suit|
                     Card::RANKS.map { |rank| Card.new(rank, suit) }
                   end)
      @cards = cards
    end

    def cards_left = cards.length
    def top_card = cards.shift
    def shuffle = cards.shuffle!
    def empty? = cards.empty?

    def self.from_json(json)
      cards = json["cards"].map do |card|
        GoFish::Card.from_json(card)
      end
      Deck.new(cards)
    end
  end
end
