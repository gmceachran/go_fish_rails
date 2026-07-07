module GoFish
  class Game
    attr_reader :active_player_index
    attr_accessor :players

    def initialize(players: players, active_player_index: 0)
      @players = players
      @active_player_index = active_player_index
    end

    def active_player = players[active_player_index]
    def self.dump(obj) = obj.as_json

    def self.load(json)
      return nil if json.nil?

      self.from_json(json)
    end

    def self.from_json(json)
      go_fish_players = json["players"].map do |player|
        Player.from_json(player)
      end

      Game.new(players: go_fish_players,
               active_player_index: json["active_player_index"])
    end

    def active_player?(user_id)
      player = players.detect { it.user_id == user_id }
      active_player_index == players.index(player)
    end

    def opponents
      current_player = [active_player]
      players - current_player
    end

    private_class_method :from_json
  end
end
