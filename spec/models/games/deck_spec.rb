require "rails_helper"

RSpec.describe Games::Deck, type: :model do
  # Games::Deck is abstract: build_cards needs a card_class. A minimal concrete
  # subclass built on the real Games::Card exercises the shared behavior once.
  let(:deck_class) do
    Class.new(Games::Deck) do
      nested_many :cards, Games::Card
      def self.card_class = Games::Card
    end
  end
  let(:deck) { deck_class.new }

  describe "the abstract contract" do
    it "requires subclasses to declare a card_class" do
      expect { Games::Deck.card_class }.to raise_error NotImplementedError
    end

    it "cannot build a deck without a card_class" do
      expect { Games::Deck.new }.to raise_error NotImplementedError
    end
  end

  describe "shared deck behavior" do
    it "builds 52 cards" do
      expect(deck.cards_left).to eq 52
    end

    it "deals the top card, shrinking the deck" do
      card = deck.top_card
      expect(card).to respond_to(:rank)
      expect(deck.cards_left).to eq 51
    end

    it "deals a distinct card each call" do
      expect(deck.top_card).not_to eq deck.top_card
    end

    describe "#shuffle" do
      it "reorders the cards" do
        decks = [ deck_class.new, deck_class.new ]
        decks.each(&:shuffle) until decks[0].cards != decks[1].cards
        expect(decks[0].cards).not_to eq decks[1].cards
      end
    end

    describe "#empty?" do
      context "when the deck has cards" do
        it "is false" do
          expect(deck).not_to be_empty
        end
      end

      context "when the deck has no cards" do
        before { deck.cards = [] }

        it "is true" do
          expect(deck).to be_empty
        end
      end
    end

    it_behaves_like "a serializable round-trip" do
      subject { deck_class.new }
    end
  end
end
