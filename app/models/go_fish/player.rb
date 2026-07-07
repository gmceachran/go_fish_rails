module GoFish
  class Player
    attr_reader :user_id
    attr_accessor :hand, :books

    def initialize(user_id: user_id, hand: [], books: [])
      @user_id = user_id
      @hand = hand
      @books = books
    end

    def self.from_json(player)
      player = Player.new(user_id: player["user_id"],
                 hand: player["hand"],
                 books: player["books"])
    end
  end
end
