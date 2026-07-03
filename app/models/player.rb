class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :game_id, uniqueness: { scope: :user, message: "You already joined this game." }
end
