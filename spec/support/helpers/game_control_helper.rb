module GameControlHelper
  def override_start(game)
    game.deck.cards = [ GoFish::Card.new(rank: "2", suit: "Spades") ]
    game.players.first.hand = [ GoFish::Card.new(rank: "3", suit: "Spades") ]
    game.players.last.hand = [ GoFish::Card.new(rank: "4", suit: "Spades") ]
  end

  def override_go_fish_win(game)
    game.deck.cards = []
    game.players.first.hand = [ GoFish::Card.new(rank: "3", suit: "Spades"),
                                 GoFish::Card.new(rank: "3", suit: "Hearts"),
                                 GoFish::Card.new(rank: "3", suit: "Diamonds") ]
    game.players.last.hand = [ GoFish::Card.new(rank: "3", suit: "Clubs") ]
    game.active_player_index = 0
  end

  def override_crazy_eights_win(game)
    game.discard_pile = [ CrazyEights::Card.new(rank: "5", suit: "Hearts") ]
    game.players.first.hand = [ CrazyEights::Card.new(rank: "5", suit: "Spades") ]
    game.players.last.hand = [ CrazyEights::Card.new(rank: "6", suit: "Diamonds") ]
    game.active_player_index = 0
  end
end
