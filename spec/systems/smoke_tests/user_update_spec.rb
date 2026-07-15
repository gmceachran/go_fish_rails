require "rails_helper"

RSpec.describe "Update Location", type: :system do
  describe "#update" do
    let!(:user) { create_and_log_in }
    before { visit user_path user }

    it "shows an update location menu" do
      click_on "Update"
      expect(page).to have_content "bingus"
    end
  end
end
