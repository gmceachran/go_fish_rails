module CrazyEights
  class Player
    attr_reader :user_id, :name
    attr_accessor :hand

    def initialize(user_id: 0, hand: [], name: "Lord Farquad")
      @user_id = user_id
      @hand = hand
      @name = name
    end

    def self.from_json(player)
      hand = player["hand"].map { |card| Card.from_json(card) }
      Player.new(user_id: player["user_id"], hand: hand, name: player["name"])
    end

    def hand_size = hand.length
  end
end
