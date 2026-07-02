class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validate :game_is_joinable
  validate :user_not_already_in_game

  private

  def game_is_joinable
    return unless game

    errors.add(:game, "is not joinable") unless game.waiting? && game.players.count < game.max_players
  end

  def user_not_already_in_game
    return unless game && user

    errors.add(:user, "already in game") if game.players.exists?(user: user)
  end
end
