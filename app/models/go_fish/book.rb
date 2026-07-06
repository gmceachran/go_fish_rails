module GoFish
  class Book
    attr_reader :rank
    RANKS = %w[ 2 3 4 5 6 7 8 9 10 J Q K A ]

    def initialize(rank) = @rank = rank
    def value = RANKS.index(rank)
  end
end
