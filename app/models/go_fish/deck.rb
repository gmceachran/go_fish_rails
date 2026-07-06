require_relative "card"

module GoFish
  class Deck
    attr_accessor :cards

    def initialize
      @cards = Card::SUITS.flat_map do |suit|
        Card::RANKS.map { |rank| Card.new(rank, suit) }
      end
    end

    def cards_left = cards.length
    def top_card = cards.shift
    def shuffle = cards.shuffle!
    def empty? = cards.empty?
  end
end
