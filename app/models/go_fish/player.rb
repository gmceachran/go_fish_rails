module GoFish
  class Player
    attr_reader :user_id, :name
    attr_accessor :hand, :books

    def initialize(user_id: user_id, hand: [], books: [], name: "Lord Farquad")
      @user_id = user_id
      @hand = hand
      @books = books
      @name = name
    end

    def self.from_json(player)
      hand = player["hand"].map do |card|
        GoFish::Card.from_json(card)
      end
      books = player["books"].map do |book|
        GoFish::Book.from_json(book)
      end

      Player.new(user_id: player["user_id"],
                hand: hand,
                books: books)
    end

    def hand_size = hand.length

    def cards_of_rank_given(rank)
      cards = hand.select { |card| card.rank == rank }
      return cards if cards.empty?

      cards.each { |card| hand.delete(card) }
    end

    def create_book_if_possible
      cards_by_rank = hand.group_by(&:rank)
      cards_by_rank.each do |rank, cards|
        next unless cards.length == 4

        books << GoFish::Book.new(rank)
        cards.each { |card| hand.delete(card) }
        return true
      end
      false
    end
  end
end
