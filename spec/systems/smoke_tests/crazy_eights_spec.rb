# spec/systems/smoke_tests/crazy_eights_spec.rb
require "rails_helper"

RSpec.describe "Crazy Eights", type: :system do
  describe "#show" do
    let(:user) { create_and_log_in }
    let(:game) { create :crazy_eights_game, max_players: 1 }

    before do
      create :player, game: game, user: user
      visit game_path game
    end

    it "shows the Crazy Eights game board" do
      expect(page).to have_current_path(game_path(game))
      expect(page).to have_content "Game #{game.id}"
      expect(page).to have_content "Your Hand"
      expect(page).to have_content "Discard Pile"
    end
  end
end
