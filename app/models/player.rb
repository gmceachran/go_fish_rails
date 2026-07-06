class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :game_id, uniqueness: { scope: :user_id, message: "You already joined this game." }
  validate :only_winner?

  after_create :start_game_if_full

  private

  def only_winner?
    return unless winner
    return if game.players.where(winner: true).where.not(id: id).empty?

    errors.add(:winner, "has already been declared for this game")
  end

  def start_game_if_full
    game.start_if_full!(game.id)
  end
end
