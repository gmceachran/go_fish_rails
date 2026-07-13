module CrazyEights
  class GameBoard
    attr_reader :game_id,
                :implementation,
                :is_clients_turn,
                :opponents,
                :player,
                :opponent_partial,
                :feed_partial,
                :discard_card,
                :wild

    def initialize(game_id:,
                  implementation:,
                  is_clients_turn:,
                  opponents:,
                  player:,
                  opponent_partial:,
                  feed_partial: nil,
                  discard_card:,
                  wild:)

      @game_id, @implementation, @is_clients_turn = game_id, implementation, is_clients_turn
      @opponents, @player = opponents, player
      @opponent_partial, @feed_partial = opponent_partial, feed_partial
      @discard_card = discard_card
      @wild = wild
    end
  end
end
