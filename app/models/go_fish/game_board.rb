module GoFish
  class GameBoard
    attr_reader :game_id,
                :implementation,
                :is_clients_turn,
                :opponents,
                :player,
                :opponent_partial,
                :feed_partial,
                :wild

    def initialize(game_id:,
                  implementation:,
                  is_clients_turn:,
                  opponents:,
                  player:,
                  opponent_partial:,
                  feed_partial: nil,
                  turn:)

      @game_id, @implementation, @is_clients_turn = game_id, implementation, is_clients_turn
      @opponents, @player = opponents, player
      @opponent_partial, @feed_partial = opponent_partial, feed_partial
      @turn = turn
    end

    def discard_card = @extras[:discard_card]
  end
end
