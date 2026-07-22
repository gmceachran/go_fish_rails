class CrazyEightsTurn < Games::Turn
  attr_accessor :rank, :suit, :action

  validate :turn_action_is_valid

  def draw? = action == "draw"

  private

  def turn_action_is_valid
    return if game_state.nil?

    draw? ? validate_draw : validate_play_card
  end

  def validate_draw
    errors.add(:action, "deck is empty") if game_state.deck.empty?
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
    player = game_state.players.detect { |p| p.user_id.to_s == user_id.to_s }
    return errors.add(:user_id, "is not a player in this game") if player.nil?

    card = player.hand.find { |hand_card| hand_card.rank == rank && hand_card.suit == suit }
    errors.add(:rank, "you don't hold this card") if card.nil?
  end

  def validate_card_matches_discard
    return if errors.any?

    card = held_card
    top_card = game_state.discard_card
    return if card.wild? || card.rank == top_card.rank || card.suit == top_card.suit

    errors.add(:rank, "must match the discard pile's rank or suit")
  end

  def held_card
    player = game_state.players.detect { |p| p.user_id.to_s == user_id.to_s }
    player.hand.find { |hand_card| hand_card.rank == rank && hand_card.suit == suit }
  end
end
