module GoFish
  class Engine < Games::Engine
    STARTING_HAND = { 1 => 7, 2 => 7, 3 => 7, 4 => 5, 5 => 5 }

    nested_many :players, GoFish::Player
    nested_one  :deck, GoFish::Deck
    nested_many :turn_results, GoFish::TurnResult

    def self.deck_class = GoFish::Deck

    def implementation_key = "go_fish"
    def opponent_partial = "games/accordion"
    def feed_partial = "games/feed"
    def deck_length = deck.cards_left

    def board_for(user_id:, game_id:)
      GameBoard.new(game_id: game_id, implementation: implementation_key,
                    is_clients_turn: active_player?(user_id), opponents: opponents,
                    player: player(user_id), opponent_partial: opponent_partial,
                    feed_partial: feed_partial, turn: Turn.new)
    end

    def start
      deck.shuffle
      deal(players, STARTING_HAND[number_of_players])
    end

    def play_turn(turn)
      player = players.detect { it.user_id.to_s == turn.user_id.to_s }
      opponent = players.detect { it.user_id.to_s == turn.opponent.to_s }
      handle_take_cards(player, opponent.cards_of_rank_given(turn.rank), turn.rank)
      handle_empty_hand
      turn_result
    end

    def advance_turn
      self.active_player_index = (active_player_index + 1) % number_of_players
      advance_turn if players[active_player_index].cant_play
    end

    def winner
      return nil unless players.all? { |player| player.hand.empty? }

      players.max_by do |player|
        best_book_value = player.books.map { |book| book.value }.max || -1
        [ player.books.length, best_book_value ]
      end
    end

    private

    def handle_take_cards(player, opponent_cards, rank)
      if opponent_cards.any?
        take_from_opponent(player, opponent_cards)
      else
        take_from_deck(player, rank)
      end
    end

    def handle_empty_hand
      players.each do |player|
        next unless player.hand.empty?
        deck.empty? ? player.cant_play = true : player.hand << deck.top_card
      end
    end

    def take_from_opponent(player, cards)
      turn_results << TurnResult.new(go_fish: false, go_again: true, cards: cards)
      player.hand.concat(cards)
      turn_result.book_made = player.create_book_if_possible
    end

    def take_from_deck(player, rank)
      turn_results << TurnResult.new(go_fish: true)
      return empty_deck if deck.empty?

      card = deck.top_card
      player.hand << card
      turn_result.cards << card
      turn_result.go_again = card.rank == rank
      turn_result.book_made = player.create_book_if_possible
    end

    def empty_deck
      turn_result.deck_empty = true
      turn_result
    end
  end
end
