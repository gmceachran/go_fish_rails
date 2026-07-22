module GoFish
  class Player < Games::Player
    scalar :cant_play
    nested_many :hand, GoFish::Card
    nested_many :books, GoFish::Book

    attr_accessor :books, :cant_play

    def initialize(books: [], cant_play: false, **rest)
      super(**rest)
      @books = books
      @cant_play = cant_play
    end

    def cards_of_rank_given(rank)
      cards = hand.select { |card| card.rank == rank }
      return cards if cards.empty?

      cards.each { |card| hand.delete(card) }
    end

    def create_book_if_possible
      hand.group_by(&:rank).each do |_rank, cards|
        next unless cards.length == 4

        books << GoFish::Book.new(cards.first.rank)
        cards.each { |card| hand.delete(card) }
        return true
      end
      false
    end
  end
end
