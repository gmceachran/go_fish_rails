require "rails_helper"

RSpec.describe CrazyEights::TurnResult, type: :model do
  let(:card) { CrazyEights::Card.new(rank: "3", suit: "Diamonds") }
  let(:turn_result) { described_class.new(drew_card: card, play_again: true) }

  describe ".from_json" do
    it "turns the given json into a ruby object" do
      restored = CrazyEights::TurnResult.from_json(turn_result.as_json)
      expect(restored.drew_card).to eq card
      expect(restored.play_again).to be true
    end
  end

  describe "wild" do
    it "preserves wild across a reload" do
      wild_result = described_class.new(wild: true)
      restored = described_class.from_json(wild_result.as_json)
      expect(restored.wild).to be true
    end
  end

  it_behaves_like "a serializable round-trip" do
    subject do
      described_class.new(drew_card: card,
                          played_card: card,
                          play_again: true,
                          wild: true)
    end
  end
end
