class CrazyEightsTurn
  include ActiveModel::Model

  attr_accessor :rank, :suit, :action, :game_id, :user_id

  validates :game_id, presence: true
  validates :user_id, presence: true

  validate :game_is_active
  validate :user_is_active_player
  validate :turn_action_is_valid

  def draw?
    action == "draw"
  end

  private

  def game
    @game ||= Game.find_by(id: game_id)
  end

  def crazy_eights_game
    game&.game_state
  end

  def game_is_active
    return errors.add(:game_id, "does not exist") if game.nil?
    errors.add(:game_id, "is not active") unless game.active?
  end

  def user_is_active_player
    return if crazy_eights_game.nil?
    errors.add(:user_id, "it is not your turn") unless crazy_eights_game.active_player?(user_id)
  end

  def turn_action_is_valid
    return if crazy_eights_game.nil?

    draw? ? validate_draw : validate_play_card
  end

  def validate_draw
    errors.add(:action, "deck is empty") if crazy_eights_game.deck.empty?
  end

  def validate_play_card
    validate_card_fields
    return if errors.any?

    validate_player_holds_card
    validate_card_matches_discard
  end

  def validate_card_fields
    errors.add(:rank, "can't be blank") if rank.blank?
    errors.add(:suit, "can't be blank") if suit.blank?
    return if rank.blank? || suit.blank?

    errors.add(:rank, "is invalid") unless CrazyEights::Card::RANKS.include?(rank)
    errors.add(:suit, "is invalid") unless CrazyEights::Card::SUITS.include?(suit)
  end

  def validate_player_holds_card
    player = crazy_eights_game.players.detect { |p| p.user_id.to_s == user_id.to_s }
    return errors.add(:user_id, "is not a player in this game") if player.nil?

    card = player.hand.find { |hand_card| hand_card.rank == rank && hand_card.suit == suit }
    errors.add(:rank, "you don't hold this card") if card.nil?
  end

  def validate_card_matches_discard
    return if errors.any?

    card = held_card
    top_card = crazy_eights_game.discard_card
    return if card.wild? || card.rank == top_card.rank || card.suit == top_card.suit

    errors.add(:rank, "must match the discard pile's rank or suit")
  end

  def held_card
    player = crazy_eights_game.players.detect { |p| p.user_id.to_s == user_id.to_s }
    player.hand.find { |hand_card| hand_card.rank == rank && hand_card.suit == suit }
  end
end
