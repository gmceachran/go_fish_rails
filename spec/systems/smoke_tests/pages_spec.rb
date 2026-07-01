require "rails_helper"

RSpec.describe "Pages", type: :system do
  describe "#rules" do
    it "shows the rules" do
      create_and_log_in
      visit pages_rules_path
      expect(page).to have_content "Rules"
    end
  end
end
