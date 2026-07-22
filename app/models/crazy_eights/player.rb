module CrazyEights
  # Crazy Eights adds nothing to the base player but the card type.
  class Player < Games::Player
    nested_many :hand, CrazyEights::Card
  end
end
