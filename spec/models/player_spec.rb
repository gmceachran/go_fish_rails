require "rails_helper"

RSpec.describe Player, type: :model do
  let(:game) { create :game }
  let(:user) { create :user }

  describe :validation do
    it "allows a player to join a game only once" do
      valid_player = build(:player, game:, user:)
      expect(valid_player).to be_valid
      valid_player.save

      invalid_player = build(:player, game:, user:)
      expect(invalid_player).to_not be_valid
      expect(invalid_player.errors.full_messages.to_sentence).to include "You already joined this game."
    end

    context "when there is no other winner in a game" do
      let(:player) { create :player }

      it "a player set to winner is valid" do
        expect(player).to be_valid
      end
    end

    context "when there is already one winner in a game" do
      let(:game) { create :game }
      let(:winner) { create :player, game: game }
      let(:looser) { create :player, game: game }
      before { winner.update winner: true }

      it "any other player set to winner is invalid" do
        looser.update winner: true
        expect(looser).to be_invalid
      end
    end
  end
end
