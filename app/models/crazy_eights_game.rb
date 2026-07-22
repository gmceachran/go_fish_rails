class CrazyEightsGame < Game
  serialize :game_state, coder: CrazyEights::Engine

  def engine_class = CrazyEights::Engine
  def player_class = CrazyEights::Player
end
