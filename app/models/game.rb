class Game < ApplicationRecord
  has_many :players
  has_many :users, through: :players

  enum :state, { waiting: 0, active: 1, over: 2 }
end
