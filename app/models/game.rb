class Game < ApplicationRecord
  after_create_commit { broadcast_refresh_later_to self }
  after_update_commit { broadcast_refresh_later_to self }


  has_many :players, dependent: :destroy
  has_many :users, through: :players

  enum :state, { waiting: 0, active: 1, over: 2 }

  validate :ended_at_validation
  validate :timestamps_match_state

  scope :not_over, -> { where.not(state: :over) }

  def joinable? = waiting? && players.count < max_players

  def start_if_full!
    return unless waiting? && players.count >= max_players
    update(started_at: Time.current, state: :active)
    update_with_starting_game_state if active?
  end

  def play_turn(turn)
    self.game_state.play_turn(turn)
  end

  def declare_winner!(player)
    player.update!(winner: true)
    update!(ended_at: Time.current, state: :over)
  end

  def declare_winner_if_over!
    winner = game_state.winner
    return unless winner

    declare_winner!(players.find_by(user_id: winner.user_id))
  end

  private

  def update_with_starting_game_state
    self.game_state = engine_class.new(players: players.order(:id).map do |player|
      player_class.new(user_id: player.user_id)
    end)
    game_state.start
    save!
  end

  def ended_at_validation
    return if ended_at.present? == players.exists?(winner: true)
    errors.add(:ended_at, "inconsistent with winner")
  end

  def timestamps_match_state
    case state
    when "waiting" then errors.add(:state, :invalid) if started_at.present?
    when "active" then errors.add(:state, :invalid) unless started_at.present? && ended_at.nil?
    when "over" then errors.add(:state, :invalid) unless started_at.present? && ended_at.present?
    end
  end
end
