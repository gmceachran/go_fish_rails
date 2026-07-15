require "rails_helper"

RSpec.describe "Profile Page", type: :system do
  let(:user) { create_and_log_in }
  before { visit user_path user }

  it "displays the profile page" do
    expect(current_path).to eq user_path user
    expect(page).to have_content "Email address:"
    expect(page).to have_content "Location:"
  end
end
