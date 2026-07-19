require "rails_helper"

RSpec.describe :offline, type: :system do
  context "when the user is offline" do
    let!(:user) { create_and_log_in }
    before do
      sleep 0.3
      driven_by :selenium_chrome_headless
    end

    it "renders the offline route from cache", pending: "not implemented yet" do
      go_offline
      expect(current_path).to be offline_path
    end
  end

  def go_offline
    page.driver.browser.network_conditions = {
      offline: true,
      latency: 0,
      throughput: 0
    }
  end
end
