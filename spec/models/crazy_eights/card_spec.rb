require "rails_helper"

RSpec.describe CrazyEights::Card, type: :model do
  describe "#wild?" do
    context "when the rank is 8" do
      let(:wild_card) { CrazyEights::Card.new(rank: "8", suit: "Spades") }

      it "is wild" do
        expect(wild_card).to be_wild
      end
    end

    context "when the rank is not 8" do
      let(:regular_card) { CrazyEights::Card.new(rank: "7", suit: "Spades") }

      it "is not wild" do
        expect(regular_card).not_to be_wild
      end
    end
  end

  it_behaves_like "a serializable round-trip" do
    subject { CrazyEights::Card.new(rank: "A", suit: "Spades") }
  end
end
