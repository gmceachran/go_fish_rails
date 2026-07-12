module CrazyEights
  class Player
    attr_reader :user_id

    def initialize(user_id: 0)
      @user_id = user_id
    end

    def self.from_json(players)
      players.map { |player| CrazyEights::Player.new(user_id: player["user_id"]) }
    end
  end
end
