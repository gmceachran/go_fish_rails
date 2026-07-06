module GoFish
  class Game
    attr_reader :game_id

    def initialize(game_id = 1)
      @game_id = game_id
    end

    def self.load(json)
      JSON.parse(json)
    end

    def self.dump(object)
      object.to_json
    end
  end
end
