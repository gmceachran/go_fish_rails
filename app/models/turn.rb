class Turn < Games::Turn
  attr_accessor :rank, :opponent

  validates :rank, presence: true, inclusion: { in: GoFish::Card::RANKS }
  validates :opponent, presence: true

  validate :opponent_is_in_game
  validate :opponent_is_not_self
  validate :user_holds_rank

  private

  def opponent_is_in_game
    return if opponent.blank? || game_state.nil?
    return if game_state.players.any? { |p| p.user_id.to_s == opponent.to_s }
    errors.add(:opponent, "is not in this game")
  end

  def opponent_is_not_self
    errors.add(:opponent, "cannot be yourself") if opponent.present? && opponent.to_s == user_id.to_s
  end

  def user_holds_rank
    return if rank.blank? || game_state.nil?
    asking_player = game_state.players.detect { |p| p.user_id.to_s == user_id.to_s }
    return errors.add(:user_id, "is not a player in this game") if asking_player.nil?
    errors.add(:rank, "you don't hold a card of this rank") unless asking_player.hand.any? { |c| c.rank == rank }
  end
end
