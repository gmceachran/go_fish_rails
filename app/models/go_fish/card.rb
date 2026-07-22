module GoFish
  class Card < Games::Card
    def value = RANKS.index(rank)
  end
end
