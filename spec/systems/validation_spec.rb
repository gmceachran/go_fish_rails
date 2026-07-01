require "rails_helper"

RSpec.describe :validation, type: :system do
  let!(:user) { build :user }

  context "when user enters valid credentials" do
    it "user is redirected to root" do
      sign_up(user.email_address, user.password)

      expect(page).to have_current_path root_path
      expect(page).to have_content "Your Games"
      expect(page).to have_content "All Games"
    end
  end

  context "when user enters invalid credentials" do
    let(:invalid) { "invalid" }

    it "user stays on sign up page" do
      sign_up(invalid, invalid)
      expect(page).to have_current_path new_user_path
    end
  end
end
