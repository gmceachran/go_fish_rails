require "rails_helper"

RSpec.describe Games::TurnResult, type: :model do
  subject(:turn_result) { described_class.new(go_again: true) }

  describe "#go_again?" do
    context "when go_again is true" do
      it "returns true" do
        expect(turn_result.go_again?).to be true
      end
    end

    context "when go_again is false" do
      subject(:turn_result) { described_class.new(go_again: false) }

      it "returns false" do
        expect(turn_result.go_again?).to be false
      end
    end
  end

  it_behaves_like "a serializable round-trip"
end
