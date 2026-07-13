require "rails_helper"

RSpec.describe CrazyEights::Card, type: :model do
  it 'has a rank and suit' do
    card = CrazyEights::Card.new('A', 'Spades')
    expect(card.rank).to eq 'A'
    expect(card.suit).to eq 'Spades'
  end

  it 'should allow valid ranks' do
    expect {
      CrazyEights::Card.new('15', 'Spades')
  }.to raise_error CrazyEights::Card::InvalidRank
  end

  it 'should allow valid suits' do
    expect {
      CrazyEights::Card.new('10', 'Minecraft')
  }.to raise_error CrazyEights::Card::InvalidSuit
  end

  describe "#from_json" do
    let(:rank) { "2" }
    let(:suit) { "Spades" }
    let(:json) { { "rank" => rank, "suit" => suit } }

    it "receives a json hash and returns a CrazyEights::Card" do
      card = CrazyEights::Card.from_json(json)
      expect(card).to be_a_kind_of CrazyEights::Card
      expect(card.rank).to eq rank
      expect(card.suit).to eq suit
    end
  end

  describe "#wild" do
    context "when card has a rank of 8" do
      let(:card) { CrazyEights::Card.new("8", "Spades") }
      it "returns true" do
        expect(card).to be_wild
      end
    end

    context "when card does not have a rank of 8" do
      let(:card) { CrazyEights::Card.new("7", "Spades") }

      it "returns false" do
        expect(card).to_not be_wild
      end
    end
  end

  describe '#to_s' do
    let(:card) { CrazyEights::Card.new('J', 'Diamonds') }
    let(:readable_card) { 'Jack of Diamonds' }

    it 'returns a readable card string' do
      expect(card.to_s).to eq readable_card
    end
  end

  describe '#data' do
    let(:card) { CrazyEights::Card.new('A', 'Spades') }
    let(:mock_data) do
      {
        rank: 'A',
        suit: 'Spades'
      }
    end

    it 'returns a hash containing data for api request' do
      expect(card.data).to eq mock_data
    end
  end
end
