class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :games, through: :players

  validates :email_address, presence: true, uniqueness: { case_insensitive: true }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, confirmation: true
  validates :password_confirmation, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
