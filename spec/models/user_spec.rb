require 'rails_helper'

RSpec.describe User, type: :model do
  let(:email) { "user@example.com" }
  let(:password) { "password" }

  context "when user enters valid credentials" do
    let(:user) { build :user }

    it "entries are valid" do
      expect(user).to be_valid
    end
  end

  context "when any credential is absent" do
    context "when email is absent" do
      let(:user) { build :user, email_address: nil }

      it "entries are invalid" do
        expect(user).to_not be_valid
      end
    end

    context "when password is absent" do
      let(:user) { build :user, password: nil }

      it "entries are invalid" do
        expect(user).to_not be_valid
      end
    end

    context "when confirm password is absent" do
      let(:user) { build :user, password_confirmation: nil }

      it "entries are invalid" do
        expect(user).to_not be_valid
      end
    end
  end

  context "when user enters an invalid email" do
    before { create :user, email_address: email }

    context "when given email already exists in database" do
      let(:user) { build :user, email_address: email }

      it "entries are invalid" do
        expect(user).to_not be_valid
      end
    end

    context "when given email is not a valid format" do
      let(:invalid_email) { "useratexample.com" }
      let(:user) { build :user, email_address: invalid_email }

      it "entries are invalid" do
        expect(user).to_not be_valid
      end
    end
  end

  context "when user's confirm password entry does not match original" do
    let(:invalid_password) { "invalid" }
    let(:user) { build :user, password_confirmation: invalid_password }

    it "entries are invalid" do
      expect(user).to_not be_valid
    end
  end
end
