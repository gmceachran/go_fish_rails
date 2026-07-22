module CrazyEights
  class Card < Games::Card
    WILD_RANK = "8"
    def wild? = rank == WILD_RANK
  end
end
