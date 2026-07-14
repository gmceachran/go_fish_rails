module GameControlHelper
  def override_start(game)
    game.deck.cards = [ GoFish::Card.new("2", "Spades") ]
    game.players.first.hand = [ GoFish::Card.new("3", "Spades") ]
    game.players.last.hand = [ GoFish::Card.new("4", "Spades") ]
    # game.save
  end
end
