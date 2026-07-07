require "rails_helper"

RSpec.describe "Games#show", type: :system do
  before do
    user = create_and_log_in
    game = create :game, max_players: 1
    create :player, game: game, user: user
    visit game_path(game)
  end

  it "shows the game" do
    expect(page).to have_content "Players"
    expect(page).to have_content "Feed"
    expect(page).to have_content "Your Hand"
    expect(page).to have_content "Books"
  end
end
