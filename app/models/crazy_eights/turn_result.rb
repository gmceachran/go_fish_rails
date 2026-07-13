module CrazyEights
  class TurnResult
    attr_accessor :drew_card, :played_card, :play_again

    def initialize(drew_card: nil, played_card: nil, play_again: false)
      @drew_card = drew_card
      @played_card = played_card
      @play_again = play_again
    end

    def self.from_json(json)
      drew_card = json["drew_card"] && Card.from_json(json["drew_card"])
      played_card = json["played_card"] && Card.from_json(json["played_card"])

      TurnResult.new(
        drew_card: drew_card,
        played_card: played_card,
        play_again: json["play_again"] || false
      )
    end

    def data
      {
        drew_card: drew_card&.data,
        played_card: played_card&.data,
        play_again: play_again
      }
    end
  end
end
