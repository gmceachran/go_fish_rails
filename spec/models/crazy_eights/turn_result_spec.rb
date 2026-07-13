require "rails_helper"

RSpec.describe CrazyEights::TurnResult, type: :model do
  let(:card) { CrazyEights::Card.new("3", "Diamonds") }
  let(:turn_result) { described_class.new(drew_card: card, play_again: true) }

  describe "#from_json" do
    let(:json) { turn_result.as_json }

    it "turns the given json into a ruby object" do
      object = CrazyEights::TurnResult.from_json(json)
      expect(object).to be_a_kind_of CrazyEights::TurnResult
      expect(object.drew_card).to eq card
      expect(object.play_again).to be true
    end
  end

  describe "#data" do
    let(:data) do
      {
        drew_card: { rank: "3", suit: "Diamonds" },
        played_card: nil, play_again: true
      }
    end

    it "it returns a hash of the instance's data" do
      expect(turn_result.data).to eq data
    end
  end
end
