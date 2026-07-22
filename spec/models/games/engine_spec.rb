require "rails_helper"

RSpec.describe Games::Engine, type: :model do
  let(:deck_class) do
    Class.new(Games::Deck) do
      nested_many :cards, Games::Card
      def self.card_class = Games::Card
    end
  end

  let(:engine_class) do
    stub_deck = deck_class
    Class.new(Games::Engine) do
      nested_many :players, Games::Player
      nested_one :deck, stub_deck
      define_singleton_method(:deck_class) { stub_deck }
    end
  end

  let(:players) do
    [
      Games::Player.new(user_id: 0, name: "Ana"),
      Games::Player.new(user_id: 1, name: "Bo")
    ]
  end

  let(:engine) { engine_class.new(players: players) }

  describe "the abstract contract" do
    it "requires subclasses to declare a deck_class" do
      expect { Games::Engine.deck_class }.to raise_error NotImplementedError
    end

    it "cannot be built without a deck_class" do
      expect { Games::Engine.new }.to raise_error NotImplementedError
    end

    it "leaves the game rules to subclasses" do
      [
        -> { engine.start }, -> { engine.advance_turn }, -> { engine.winner },
        -> { engine.implementation_key }, -> { engine.play_turn(nil) },
        -> { engine.board_for(user_id: 0, game_id: 1) }
      ].each do |rule|
        expect(&rule).to raise_error NotImplementedError
      end
    end
  end

  describe "shared queries" do
    describe "#active_player" do
      it "returns the player at the active index" do
        expect(engine.active_player).to eq players.first
      end
    end

    describe "#player" do
      it "finds the player by user_id" do
        expect(engine.player(1)).to eq players.last
      end
    end

    describe "#active_player?" do
      context "when the id matches the active player" do
        it "is true" do
          expect(engine.active_player?(0)).to be true
        end
      end

      context "when the id does not match" do
        it "is false" do
          expect(engine.active_player?(1)).to be false
        end
      end
    end

    describe "#opponents" do
      it "returns every player but the active one" do
        expect(engine.opponents).to eq [ players.last ]
      end
    end

    describe "#number_of_players" do
      it "counts the players" do
        expect(engine.number_of_players).to eq 2
      end
    end

    describe "#turn_result" do
      before { engine.turn_results = [ :first, :last ] }

      it "returns the most recent turn result" do
        expect(engine.turn_result).to eq :last
      end
    end
  end

  describe "serialization" do
    it "loads nil json as nil" do
      expect(Games::Engine.load(nil)).to be_nil
    end

    it_behaves_like "a serializable round-trip" do
      subject { engine_class.new(players: players, active_player_index: 1) }
    end
  end
end
