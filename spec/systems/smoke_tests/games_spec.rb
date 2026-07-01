require "rails_helper"


RSpec.describe "Games", type: :system do
  describe "#index" do
    it "shows the game index" do
      create_and_log_in
      visit games_path

      expect(page).to have_content "Your Games"
      expect(page).to have_content "All Games"
    end
  end

  describe "#history" do
    it 'shows game history' do
      create_and_log_in
      visit games_history_path
      expect(page).to have_content "History"
    end
  end
end
