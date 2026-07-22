RSpec.shared_examples "a turn for an active game and the active player's turn" do
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  describe "presence" do
    it "requires a game_id" do
      subject.game_id = nil
      expect(subject).not_to be_valid
    end

    it "requires a user_id" do
      subject.user_id = nil
      expect(subject).not_to be_valid
    end
  end

  describe "game state" do
    context "when the game does not exist" do
      let(:nonexistent_game_id) { -1 }

      it "is invalid" do
        subject.game_id = nonexistent_game_id
        expect(subject).not_to be_valid
      end
    end

    context "when the game is not active" do
      let(:waiting_game) { create :game, type: game.class.name, max_players: 2 }

      it "is invalid" do
        subject.game_id = waiting_game.id
        expect(subject).not_to be_valid
      end
    end
  end

  describe "turn order" do
    it "rejects a user who is not the active player" do
      subject.user_id = opponent_player.user_id
      expect(subject).not_to be_valid
    end
  end
end
