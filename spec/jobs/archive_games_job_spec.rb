require 'rails_helper'

RSpec.describe ArchiveGamesJob, type: :job do
  context "when a game is over" do
    let!(:game) { create :game, :finished }

    it "archives the game" do
      game_record = Game.find(game.id)
      expect(game_record.archived_at).to_not be_nil
    end
  end
end
