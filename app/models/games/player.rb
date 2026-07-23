module Games
  class Player
    include Games::Serializable
    scalar :user_id, :name

    attr_reader :user_id, :name
    attr_accessor :hand

    def initialize(user_id: nil, hand: [], name: "Lord Farquad")
      @user_id = user_id&.to_i
      @hand = hand
      @name = name
    end

    def hand_size = hand.length
  end
end
