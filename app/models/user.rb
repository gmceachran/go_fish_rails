class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :games, through: :players

  validates :email_address, presence: true, uniqueness: { case_insensitive: true }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, confirmation: true
  validates :password_confirmation, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def games_played_count
    games.where(state: :over).count
  end

  def games_won_count
    players.where(winner: true).count
  end

  def win_percentage
    return 0 if games_played_count.zero?

    (games_won_count.to_f / games_played_count * 100).round(1)
  end
end
