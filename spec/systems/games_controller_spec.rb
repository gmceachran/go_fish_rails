require "rails_helper"

RSpec.describe :create_game, type: :system do
  before { create_and_log_in }

  context "when a user clicks create game" do
   it "opens the create game form" do
      visit root_path
      click_on "New Game"

      expect(page).to have_content "Choose Number of Players"
      expect(page).to have_content "Create New Game"
    end
  end

  context "when a user submits the create game form" do
    it "adds the game to the list" do
      visit root_path
      click_on "New Game"
      click_on "Create Game"

      expect(page).to have_content "players"
      expect(page).to have_content "waiting"
    end
  end
end
