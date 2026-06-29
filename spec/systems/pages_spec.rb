require "rails_helper"

RSpec.describe "Pages", type: :system do
  describe "#rules" do
    it "shows the rules" do
      visit "/pages/rules"
      expect(page).to have_content "Rules"
    end
  end
end
