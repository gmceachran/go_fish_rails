require "rails_helper"

RSpec.describe :edit_address, type: :system do
  describe "#edit" do
    let(:user) { create_and_log_in }

    before do
      visit user_path user
      click_on "Update"
    end

    it "updates the user's location" do
      update_location
      user_model = User.find(user.id)

      expect(user_model.state).to eq "WA"
      expect(user_model.country).to eq "US"
    end

    def update_location
      select "United States", from: "Country"
      select "Washington", from: "State"
      click_on "Update Location"
    end
  end
end
