class GoFishGame < Game
  serialize :game_state, coder: GoFish::Engine

  def start_if_full!
    super
    update_with_starting_game_state if active?
  end

  private

  def update_with_starting_game_state
    self.game_state = GoFish::Engine.new(players: players.order(:id).map do |player|
      GoFish::Player.new(user_id: player.user_id)
    end)
    self.game_state.start
    save!
  end
end
