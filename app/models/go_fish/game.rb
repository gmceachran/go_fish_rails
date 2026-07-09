module GoFish
  class Game
    attr_reader :active_player_index
    attr_accessor :players, :deck

    STARTING_HAND = {
      1 => 7,
      2 => 7,
      3 => 7,
      4 => 5,
      5 => 5
    }

    def initialize(players: players,
                   active_player_index: 0,
                   deck: GoFish::Deck.new)
      @players = players
      @active_player_index = active_player_index
      @deck = deck
    end

    def active_player = players[active_player_index]
    def deck_length = deck.cards_left
    def self.dump(obj) = obj.as_json

    def self.load(json)
      return nil if json.nil?

      self.from_json(json)
    end

    def self.from_json(json)
      go_fish_players = json["players"].map do |player|
        Player.from_json(player)
      end
      deck = Deck.from_json(json["deck"])

      Game.new(players: go_fish_players,
               active_player_index: json["active_player_index"],
               deck: deck)
    end

    def active_player?(user_id)
      player = players.detect { it.user_id == user_id }
      active_player_index == players.index(player)
    end

    def opponents
      current_player = [ active_player ]
      players - current_player
    end

    def start
      deck.shuffle
      deal(players, STARTING_HAND[number_of_players])
    end

    def take_turn(turn)
      binding.irb
    end

    private_class_method :from_json
    private

    def number_of_players = players.length

    def deal(players, num)
      players.each do |player|
        num.times do
          card = deck.top_card
          player.hand << card
        end
      end
    end
  end
end
