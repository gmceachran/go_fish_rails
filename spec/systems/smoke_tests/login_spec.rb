require "rails_helper"

RSpec.describe "Sessions", type: :system do
  describe "#new" do
    it 'shows login form' do
      visit new_session_path

      expect(page).to have_button "Log in"
      expect(page).to have_content "Forgot password?"
    end
  end
end
