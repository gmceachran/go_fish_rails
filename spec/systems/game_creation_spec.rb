require "rails_helper"

RSpec.describe :create_game, type: :system do
  let!(:user) { create_and_log_in }

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
      expect do
        visit root_path
        click_on "New Game"
        click_on "Create Game"
        visit current_path
      end.to change { user.games.count }.by 1
    end
  end

  context "when a user submits the create game form with a selected player count" do
    before do
      visit root_path
      click_on "New Game"
      select "3", from: "Number of players"
      click_on "Create Game"
    end

    it "creates a game with the selected max players and shows it" do
      game = Game.last
      expect(game.max_players).to eq 3
      expect(game.players.count).to eq 1

      within ".your-games" do
        expect(page).to have_content "#{game.players.count}/#{game.max_players} players"
      end
    end
  end

  context "when a user joins a game" do
    before do
      create :game
      visit root_path
      click_on "New Game"
      click_on "Create Game"
    end

    it "the game is added to 'your games'" do
      visit root_path
      open_games = find("[data-testid='open-games']").all(".card", text: "Join")
      expect(open_games.length).to be 1
      click_on "Join"
      new_open_games = find("[data-testid='open-games']").all(".card", text: "Join")
      expect(new_open_games).to be_empty
    end
  end
end
