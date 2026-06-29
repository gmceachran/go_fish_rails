require "rails_helper"

RSpec.describe "Games", type: :system do
  describe "#index" do
    it 'shows player stats' do
      visit "/stats"
      expect(page).to have_content "Stats"
    end
  end
end
