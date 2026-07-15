require "rails_helper"

RSpec.describe "Profile Page", type: :system do
  let(:user) { create_and_log_in }
  before { visit users_path(user.id) }

  it "displays the profile page", pending: "content not finished" do
    expect(current_path).to eq users_path user.id
    expect(page).to have_content "email address"
    expect(page).to have_content "address"
  end

  # something about editing
end
