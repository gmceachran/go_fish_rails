module Games
  class Turn
    include ActiveModel::Model

    attr_accessor :game_id, :user_id, :game_record

    validates :game_id, presence: true
    validates :user_id, presence: true
    validate :game_is_active
    validate :user_is_active_player

    def game
      self.game_record ||= Game.find_by(id: game_id)
    end

    def game_state = game&.game_state

    private

    def game_is_active
      return errors.add(:game_id, "does not exist") if game.nil?
      errors.add(:game_id, "is not active") unless game.active?
    end

    def user_is_active_player
      return if game_state.nil?
      errors.add(:user_id, "it is not your turn") unless game_state.active_player?(user_id)
    end
  end
end
