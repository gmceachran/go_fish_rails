require 'rails_helper'

RSpec.describe ArchiveGamesJob, type: :job do
  context "when a game is over" do
    let!(:game) { create :game, :finished }
    before { ArchiveGamesJob.perform_now }

    it "archives the game" do
      game_record = Game.find(game.id)
      expect(game_record.archived_at).to_not be_nil
    end
  end


  context "when game was updated less than two days ago" do
    let!(:game) { create :game, updated_at: 1.day.ago }
    before { ArchiveGamesJob.perform_now }

    it "is not archived" do
      game_model = Game.find(game.id)
      expect(game_model.archived_at).to be_nil
    end
  end

  context "when game has not been updated for two days" do
    let!(:game) { create :game, updated_at: 2.days.ago }
    before { ArchiveGamesJob.perform_now }

    it "is archived" do
      game_model = Game.find(game.id)
      expect(game_model.archived_at).to_not be_nil
    end
  end

  context "when game has already been archived" do
    let!(:archive_time) { 1.day.ago }
    let!(:game) { create :game, :finished, archived_at: archive_time }
    before { ArchiveGamesJob.perform_later }

    it "is not archived again" do
      game_model = Game.find(game.id)
      expect(game_model.archived_at).to eq archive_time
    end
  end
end
