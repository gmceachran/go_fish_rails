module GoFish
  class Game
    attr_reader :game_id

    def initialize(game_id = 1)
      @game_id = game_id
    end

    def self.load(json)
      JSON.parse(json)
    end

    def dump
      { "game_id" => game_id }.to_json
    end
  end
end
