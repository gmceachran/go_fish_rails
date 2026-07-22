module CrazyEights
  class TurnResult
    include Games::Serializable
    scalar :play_again, :wild
    nested_one :drew_card, CrazyEights::Card
    nested_one :played_card, CrazyEights::Card

    attr_accessor :drew_card, :played_card, :play_again, :wild

    def initialize(drew_card: nil, played_card: nil, play_again: false, wild: false)
      @drew_card = drew_card
      @played_card = played_card
      @play_again = play_again
      @wild = wild
    end
  end
end
