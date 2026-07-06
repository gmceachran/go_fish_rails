module GoFish
  class Player
    attr_reader :user_id
    attr_accessor :hand, :books

    def initialize(user_id = 0)
      @user_id = user_id
      @hand = []
      @books = []
    end
  end
end
