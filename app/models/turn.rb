class Turn
  include ActiveModel::Model

  attr_accessor :rank, :opponent, :game_id, :user_id

  validates :rank, presence: true, inclusion: { in: GoFish::Card::RANKS }
  validates :opponent, presence: true
  validates :game_id, presence: true
  validates :user_id, presence: true

  validate :game_is_active
  validate :opponent_is_in_game
  validate :opponent_is_not_self
  validate :user_is_active_player
  validate :user_holds_rank

  private

  def game
    @game ||= Game.find_by(id: game_id)
  end

  def go_fish_game
    game&.game_state
  end

  def game_is_active
    return errors.add(:game_id, "does not exist") if game.nil?
    errors.add(:game_id, "is not active") unless game.active?
  end

  def opponent_is_in_game
    return if opponent.blank? || go_fish_game.nil?
    return if go_fish_game.players.any? { |p| p.user_id.to_s == opponent.to_s }
    errors.add(:opponent, "is not in this game")
  end

  def opponent_is_not_self
    errors.add(:opponent, "cannot be yourself") if opponent.present? && opponent.to_s == user_id.to_s
  end

  def user_is_active_player
    return if go_fish_game.nil?
    errors.add(:user_id, "it is not your turn") unless go_fish_game.active_player?(user_id)
  end

  def user_holds_rank
    return if rank.blank? || go_fish_game.nil?
    asking_player = go_fish_game.players.detect { |p| p.user_id.to_s == user_id.to_s }
    return errors.add(:user_id, "is not a player in this game") if asking_player.nil?
    errors.add(:rank, "you don't hold a card of this rank") unless asking_player.hand.any? { |c| c.rank == rank }
  end
end
