module CrazyEights
  class Deck < Games::Deck
    nested_many :cards, CrazyEights::Card
    def self.card_class = CrazyEights::Card
  end
end
