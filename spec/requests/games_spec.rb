require "rails_helper"

RSpec.describe "Games", type: :request do
  describe "GET /games/:id" do
    let!(:user) { create :user }

    before do
      post session_path, params: {
        session: {
          email_address: user.email_address,
          password: user.password
        }
      }
    end

    context "when the game does not exist" do
      it "returns not found" do
        get game_path(id: 999999)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
