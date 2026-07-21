module GameControlHelper
  def override_start(game)
    game.deck.cards = [ GoFish::Card.new("2", "Spades") ]
    game.players.first.hand = [ GoFish::Card.new("3", "Spades") ]
    game.players.last.hand = [ GoFish::Card.new("4", "Spades") ]
  end

  def override_go_fish_win(game)
    game.deck.cards = []
    game.players.first.hand = [ GoFish::Card.new("3", "Spades"),
                                 GoFish::Card.new("3", "Hearts"),
                                 GoFish::Card.new("3", "Diamonds") ]
    game.players.last.hand = [ GoFish::Card.new("3", "Clubs") ]
    game.active_player_index = 0
  end

  def override_crazy_eights_win(game)
    game.discard_pile = [ CrazyEights::Card.new("5", "Hearts") ]
    game.players.first.hand = [ CrazyEights::Card.new("5", "Spades") ]
    game.players.last.hand = [ CrazyEights::Card.new("6", "Diamonds") ]
    game.active_player_index = 0
  end
end
