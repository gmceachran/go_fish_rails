class CrazyEightsGame < Game
  serialize :game_state, coder: CrazyEights::Implementation

  def start_if_full!
    super
    update_with_starting_game_state if active?
  end

  private

  def update_with_starting_game_state
    self.game_state = CrazyEights::Implementation.new(players: players.order(:id).map do |player|
      CrazyEights::Player.new(user_id: player.user_id)
    end)
    self.game_state.start
    save!
  end
end
