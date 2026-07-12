module GoFish
  class Implementation < ::GameImplementation
    STARTING_HAND = {
      1 => 7,
      2 => 7,
      3 => 7,
      4 => 5,
      5 => 5
    }

    attr_accessor :deck, :active_player_index, :turn_results

    def initialize(players: [],
                   active_player_index: 0,
                   deck: GoFish::Deck.new,
                   turn_results: [])

      super(players: players)

      @active_player_index = active_player_index
      @deck = deck
      @turn_results = turn_results
    end

    def active_player = players[active_player_index]
    def deck_length = deck.cards_left
    def turn_result = turn_results.last

    def self.from_json(json)
      go_fish_players = json["players"].map do |player|
        Player.from_json(player)
      end
      deck = Deck.from_json(json["deck"])
      results = (json["turn_results"] || []).map { |result| TurnResult.from_json(result) }

      Implementation.new(players: go_fish_players,
               active_player_index: json["active_player_index"],
               deck: deck,
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
      current_player = [ active_player ]
      players - current_player
    end

    def start
      deck.shuffle
      deal(players, STARTING_HAND[number_of_players])
    end

    def play_turn(turn)
      player = players.detect { it.user_id.to_s == turn.user_id.to_s }
      opponent = players.detect { it.user_id.to_s == turn.opponent.to_s }
      opponent_cards = opponent.cards_of_rank_given(turn.rank)

      handle_take_cards(player, opponent_cards, turn.rank)
      handle_empty_hand

      turn_result
    end

    def advance_turn
      if active_player_index == (number_of_players - 1)
        self.active_player_index = 0
      else
        self.active_player_index += 1
      end

      advance_turn if players[active_player_index].cant_play
    end

    def winner
      return nil unless players.all? { |player| player.hand.empty? }

      winner = players.max_by do |player|
        best_book_value = player.books.map { |book| book.value }.max || -1
        [ player.books.length, best_book_value ]
      end
      winner
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
