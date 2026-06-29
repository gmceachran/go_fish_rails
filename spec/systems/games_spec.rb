require "rails_helper"


RSpec.describe "Games", type: :system do

  describe "#index" do
    it "shows the game index" do
      visit games_path

      expect(page).to have_content "Your Games"
      expect(page).to have_content "All Games"
    end
  end

  describe "#history" do
    it 'shows game history' do
      visit games_history_path
      expect(page).to have_content "History"
    end
  end
end
