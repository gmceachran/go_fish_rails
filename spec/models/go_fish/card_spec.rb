require "rails_helper"

RSpec.describe GoFish::Card, type: :model do
  it 'has a rank and suit' do
    card = GoFish::Card.new('A', 'Spades')
    expect(card.rank).to eq 'A'
    expect(card.suit).to eq 'Spades'
  end

  it 'should allow valid ranks' do
    expect {
      GoFish::Card.new('15', 'Spades')
  }.to raise_error GoFish::Card::InvalidRank
  end

  it 'should allow valid suits' do
    expect {
      GoFish::Card.new('10', 'Minecraft')
  }.to raise_error GoFish::Card::InvalidSuit
  end

  describe '#value' do
    it 'returns the index of the given rank' do
      card = GoFish::Card.new('4', 'Spades')
      expect(card.value).to be 2
    end
  end

  describe '#to_s' do
    let(:card) { GoFish::Card.new('J', 'Diamonds') }
    let(:readable_card) { 'Jack of Diamonds' }

    it 'returns a readable card string' do
      expect(card.to_s).to eq readable_card
    end
  end

  describe '#data' do
    let(:card) { GoFish::Card.new('A', 'Spades') }
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
