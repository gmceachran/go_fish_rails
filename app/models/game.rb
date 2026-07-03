class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :users, through: :players

  enum :state, { waiting: 0, active: 1, over: 2 }

  def joinable? = waiting? && players.count < max_players
end
