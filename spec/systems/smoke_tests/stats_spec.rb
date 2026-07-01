require "rails_helper"

RSpec.describe "Games", type: :system do
  describe "#index" do
    it 'shows player stats' do
      create_and_log_in
      visit stats_path
      expect(page).to have_content "Stats"
    end
  end
end
