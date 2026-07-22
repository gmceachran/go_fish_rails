module Games
  class Card
    include Games::Serializable
    scalar :rank, :suit

    class InvalidRank < StandardError; end
    class InvalidSuit < StandardError; end

    RANKS = %w[ 2 3 4 5 6 7 8 9 10 J Q K A ]
    SUITS = %w[ Spades Clubs Hearts Diamonds ]
    RANKS_TO_NAMES = {
      "2" => "Two", "3" => "Three", "4" => "Four", "5" => "Five", "6" => "Six",
      "7" => "Seven", "8" => "Eight", "9" => "Nine", "10" => "Ten", "J" => "Jack",
      "Q" => "Queen", "K" => "King", "A" => "Ace"
    }

    attr_reader :rank, :suit

    def initialize(rank:, suit:)
      raise InvalidRank unless RANKS.include?(rank)
      raise InvalidSuit unless SUITS.include?(suit)
      @rank = rank
      @suit = suit
    end

    def ==(other) = rank == other.rank && suit == other.suit
    def to_s = "#{RANKS_TO_NAMES[rank]} of #{suit}"
  end
end
