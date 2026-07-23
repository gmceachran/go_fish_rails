module Games
  class TurnResult
    include Games::Serializable
    scalar :go_again

    attr_accessor :go_again

    def initialize(go_again: false)
      @go_again = go_again
    end

    def go_again? = go_again
  end
end
