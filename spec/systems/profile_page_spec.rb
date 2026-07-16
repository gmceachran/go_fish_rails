require "rails_helper"

RSpec.describe :visit_profile_page, type: :system do
  let!(:user) { create_and_log_in }
  before { visit root_path }

  context "when user clicks on the profile button" do
    it "redirects to the profile page" do
      click_on "Profile"
      expect(current_path).to eq user_path user
    end
  end
end
