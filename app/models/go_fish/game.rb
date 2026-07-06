module GoFish
  class Game
    attr_reader :game_id
    attr_accessor :players

    def initialize(game_id = 0)
      @game_id = game_id
      @players = []
    end

    # ASK: this seems to make more sense as an instance method
    def dump = as_json.to_json

    def self.load(json)
      JSON.parse(json)
    end


    def add_player(user_id)
      players << Player.new(user_id)
    end

    private

    def as_json
      {
        game_id: game_id,
        players: players.map(&:as_json)
      }
    end
  end
end
