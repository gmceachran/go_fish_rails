require "rails_helper"

RSpec.describe :authentication, type: :system do
  let!(:user) { create :user }

  context "when user logs uses valid credentials" do
    it "user is redirected to root page" do
      log_in(user.email_address, user.password)

      expect(page).to have_current_path root_path
      expect(page).to have_content "Your Games"
      expect(page).to have_content "All Games"
    end
  end

  context "when user logs in with invalid credentials" do
    let(:invalid) { "invalid" }

    it "user stays on login page" do
      log_in(invalid, invalid)
      expect(page).to have_current_path new_session_path
    end
  end

  def log_in(email, password)
    visit new_session_path
    fill_in "email_address", with: email
    fill_in "password", with: password
    click_on "Sign in"
  end
end
