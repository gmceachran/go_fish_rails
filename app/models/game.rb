class Game < ApplicationRecord
  # serialize :go_fish, GoFish::Game
  # ASK: what does this do? Doesn't seem necessary so far

  has_many :players, dependent: :destroy
  has_many :users, through: :players

  enum :state, { waiting: 0, active: 1, over: 2 }

  validate :ended_at_validation
  validate :timestamps_match_state

  def joinable? = waiting? && players.count < max_players

  def start_if_full!(game_id)
    return unless waiting? && players.count >= max_players

    update(started_at: Time.current, state: :active)
    update_with_starting_game_state(game_id)
  end

  def declare_winner!(player)
    player.update!(winner: true)
    update!(ended_at: Time.current, state: :over)
  end

  private

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

  def update_with_starting_game_state(game_id)
    game = GoFish::Game.new(game_id)
    game_data = Game.find(game_id)
    game_data.players.each { |player| game.add_player(player.user_id) }
    json = game.dump
    game_data.update(go_fish: json)
  end
end
