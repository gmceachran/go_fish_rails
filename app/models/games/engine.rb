module Games
  class Engine
    include Games::Serializable
    scalar :active_player_index

    attr_accessor :players, :deck, :active_player_index, :turn_results

    def initialize(players: [], active_player_index: 0, deck: nil, turn_results: [])
      @players = players
      @active_player_index = active_player_index
      @deck = deck || self.class.deck_class.new
      @turn_results = turn_results
    end

    def self.load(json) = json.nil? ? nil : from_json(json)
    def self.dump(obj) = obj.as_json
    def self.deck_class = raise NotImplementedError

    def active_player = players[active_player_index]
    def turn_result = turn_results.last
    def number_of_players = players.length
    def player(user_id) = players.detect { it.user_id == user_id }
    def active_player?(user_id) = active_player_index == players.index(player(user_id))
    def opponents = players - [ active_player ]

    def opponent_partial = "games/opponent"

    def implementation_key = raise NotImplementedError
    def start = raise NotImplementedError
    def play_turn(turn) = raise NotImplementedError
    def advance_turn = raise NotImplementedError
    def winner = raise NotImplementedError
    def board_for(user_id:, game_id:) = raise NotImplementedError

    private

    def deal(players, num)
      players.each { |player| num.times { player.hand << deck.top_card } }
    end
  end
end
