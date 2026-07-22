module GoFish
  class Deck < Games::Deck
    nested_many :cards, GoFish::Card
    def self.card_class = GoFish::Card
  end
end
