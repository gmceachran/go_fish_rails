module CrazyEights
  class Engine < Games::Engine
    STARTING_HAND = {
      1 => 7,
      2 => 7,
      3 => 5,
      4 => 5,
      5 => 5
    }.freeze

    attr_accessor :deck,
                  :discard_pile,
                  :active_player_index,
                  :turn_results,
                  :discard_pile

    def initialize(players: [],
                   active_player_index: 0,
                   deck: Deck.new,
                   discard_pile: [],
                   turn_results: [])

      super(players: players)
      @active_player_index = active_player_index
      @deck = deck
      @discard_pile = discard_pile
      @turn_results = turn_results
    end

    def active_player = players[active_player_index]
    def discard_card = discard_pile.last
    def implementation_key = "crazy_eights"
    def turn_result = turn_results.last
    def feed_partial = "games/crazy_eights_feed"

    def self.from_json(json)
      players = json["players"].map { |player| Player.from_json(player) }
      deck = Deck.from_json(json["deck"])
      discard_pile = json["discard_pile"].nil? ? [] : json["discard_pile"].map { |card| Card.from_json(card) }
      results = json["turn_results"].map { |result| TurnResult.from_json(result) }

      Engine.new(players: players,
                         active_player_index: json["active_player_index"],
                         deck: deck,
                         discard_pile: discard_pile,
                         turn_results: results)
    end

    def active_player?(user_id)
      player = player(user_id)
      active_player_index == players.index(player)
    end

    def player(user_id)
      players.detect { it.user_id == user_id }
    end

    def opponents
      players - [ active_player ]
    end

    def board_for(user_id:, game_id:)
      GameBoard.new(game_id: game_id,
                    implementation: implementation_key,
                    is_clients_turn: active_player?(user_id),
                    opponents: opponents,
                    player: player(user_id),
                    opponent_partial: opponent_partial,
                    feed_partial: feed_partial,
                    discard_card: discard_card,
                    wild: turn_result.nil? ? false : turn_result.wild)
    end

    def start
      deck.shuffle
      deal(players, STARTING_HAND[number_of_players])
      start_discard_pile
    end

    def play_turn(turn)
      player = players.detect { it.user_id.to_s == turn.user_id.to_s }
      turn.draw? ? handle_draw(player) : handle_play_card(player, turn.rank, turn.suit)
      turn_result
    end

    def advance_turn
      self.active_player_index = next_player_index
    end

    def winner
      return nil if discard_pile.empty?

      players.detect { it.hand.empty? }
    end

    private_class_method :from_json
    private

    def number_of_players = players.length

    def next_player_index
      return 0 if active_player_index == (number_of_players - 1)

      active_player_index + 1
    end

    def deal(players, num)
      players.each { |player| deal_to(player, num) }
    end

    def deal_to(player, num)
      num.times { player.hand << deck.top_card }
    end

    def start_discard_pile
      return if deck.empty?

      card = deck.top_card
      discard_pile << card if card
    end

    def handle_play_card(player, rank, suit)
      card = player.hand.find { |hand_card| hand_card.rank == rank && hand_card.suit == suit }
      return unless card && playable?(card)

      play_card(player, card)
    end

    def play_card(player, card)
      player.hand.delete(card)
      discard_pile << card
      turn_results << TurnResult.new(played_card: card, wild: card.wild?)
    end

    def handle_draw(player)
      return if deck.empty?

      card = deck.top_card
      player.hand << card
      turn_results << TurnResult.new(drew_card: card, play_again: true)
    end

    def playable?(card)
      top_card = discard_card
      card.wild? || card.rank == top_card.rank || card.suit == top_card.suit
    end
  end
end
