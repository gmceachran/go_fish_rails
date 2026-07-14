require "rails_helper"

RSpec.describe CrazyEights::Deck, type: :model do
  let(:deck) { CrazyEights::Deck.new }

  it 'Should have 52 cards when created' do
    expect(deck.cards_left).to eq 52
  end

  it 'should deal the top card' do
    card = deck.top_card
    expect(card).to_not be_nil
    expect(card).to respond_to(:rank)
    expect(deck.cards_left).to eq 51
  end

  it 'deal gives a unique card each time' do
    card1 = deck.top_card
    card2 = deck.top_card
    expect(card1).not_to eq card2
  end

  it 'cards of the same rank and suite are equal' do
    card1 = CrazyEights::Card.new('A', 'Spades')
    card2 = CrazyEights::Card.new('K', 'Spades')
    card3 = CrazyEights::Card.new('A', 'Spades')

    expect(card1).not_to eq card2
    expect(card1).to eq card3
  end

  describe '#shuffle' do
    it 'returns a shuffled card deck' do
      decks = [CrazyEights::Deck.new, CrazyEights::Deck.new]
      decks.map { |deck| deck.shuffle } until decks[0].cards != decks[1].cards
      expect(decks[0]).to_not eq decks[1]
    end
  end

  describe '#empty?' do
    context 'when deck is not empty' do
      it 'returns false' do
        expect(deck).not_to be_empty
      end
    end

    context 'when deck is empty' do
      before { deck.cards = [] }
      it 'returns true ' do
        expect(deck).to be_empty
      end
    end
  end

  describe "#from_json" do
    let(:json) do
      {
        "cards" => [
          { "rank" => "2", "suit" => "Spades" },
          { "rank" => "3", "suit" => "Spades" }
        ]
      }
    end

    it "receives a json hash and returns a deck object" do
      deck = CrazyEights::Deck.from_json(json)
      expect(deck).to be_a_kind_of CrazyEights::Deck
      expect(deck.cards.first).to be_a_kind_of CrazyEights::Card
    end
  end
end
