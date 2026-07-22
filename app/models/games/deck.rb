module Games
  class Deck
    include Games::Serializable

    attr_accessor :cards

    def initialize(cards: nil) = @cards = cards || self.class.build_cards

    def cards_left = cards.length
    def top_card = cards.shift
    def shuffle = cards.shuffle!
    def empty? = cards.empty?

    def self.card_class = raise NotImplementedError

    def self.build_cards
      card_class::SUITS.flat_map do |suit|
        card_class::RANKS.map { |rank| card_class.new(rank: rank, suit: suit) }
      end
    end
  end
end
