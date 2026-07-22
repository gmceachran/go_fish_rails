class GoFishGame < Game
  serialize :game_state, coder: GoFish::Engine

  def engine_class = GoFish::Engine
  def player_class = GoFish::Player
end
