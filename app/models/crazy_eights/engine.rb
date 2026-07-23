module CrazyEights
  class Engine < Games::Engine
    STARTING_HAND = { 1 => 7, 2 => 7, 3 => 5, 4 => 5, 5 => 5 }.freeze

    nested_many :players, CrazyEights::Player
    nested_one  :deck, CrazyEights::Deck
    nested_many :turn_results, CrazyEights::TurnResult
    nested_many :discard_pile, CrazyEights::Card

    attr_accessor :discard_pile

    def self.deck_class = CrazyEights::Deck

    def initialize(discard_pile: [], **rest)
      super(**rest)
      @discard_pile = discard_pile
    end

    def implementation_key = "crazy_eights"
    def feed_partial = "games/crazy_eights_feed"
    def discard_card = discard_pile.last

    def board_for(user_id:, game_id:)
      GameBoard.new(game_id: game_id, implementation: implementation_key,
                    is_clients_turn: active_player?(user_id), opponents: opponents,
                    player: player(user_id), opponent_partial: opponent_partial,
                    feed_partial: feed_partial, discard_card: discard_card,
                    wild: turn_result&.wild || false)
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
      self.active_player_index = (active_player_index + 1) % number_of_players
    end

    def winner
      return nil if discard_pile.empty?

      players.detect { it.hand.empty? }
    end

    private

    def start_discard_pile
      return if deck.empty?

      discard_pile << deck.top_card
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
      turn_results << TurnResult.new(drew_card: card, go_again: true)
    end

    def playable?(card)
      card.wild? || card.rank == discard_card.rank || card.suit == discard_card.suit
    end
  end
end
