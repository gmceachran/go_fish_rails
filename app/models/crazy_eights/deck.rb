require_relative "card"

module CrazyEights
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
      cards = json["cards"].map { |card| CrazyEights::Card.from_json(card) }
      Deck.new(cards)
    end
  end
end
