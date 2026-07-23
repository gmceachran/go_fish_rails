module CrazyEights
  class TurnResult < Games::TurnResult
    scalar :wild
    nested_one :drew_card, CrazyEights::Card
    nested_one :played_card, CrazyEights::Card

    attr_accessor :drew_card, :played_card, :wild

    def initialize(drew_card: nil, played_card: nil, go_again: false, wild: false)
      super(go_again: go_again)
      @drew_card = drew_card
      @played_card = played_card
      @wild = wild
    end
  end
end
