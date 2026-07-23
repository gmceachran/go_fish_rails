class GoFishGame < Game
  serialize :game_state, coder: GoFish::Engine

  def engine_class = GoFish::Engine
  def player_class = GoFish::Player
  def turn_class = Turn
  def turn_params_keys = [ :rank, :opponent ]
end
