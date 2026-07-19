require "rails_helper"

RSpec.describe "Offline page", type: :system do
  it "renders the offline page without authentication" do
    visit offline_path

    expect(page).to have_current_path offline_path
    expect(page).to have_content "You're offline"
    expect(page).to have_css "img[alt='Game Platform']"
  end
end
