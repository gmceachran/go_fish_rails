require "rails_helper"

RSpec.describe "Passwords", type: :system do
  describe "#new" do
    it 'shows forgot password form' do
      visit new_password_path

      expect(page).to have_content "Forgot your password?"
      expect(page).to have_button "Email reset instructions"
    end
  end
end
