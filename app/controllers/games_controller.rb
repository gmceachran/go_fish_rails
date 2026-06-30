class GamesController < ApplicationController
  def index
  end

  def history
    @game_history = [
      {
        title: "Game 1",
        player_count: 3,
        won: false
      },
      {
        title: "Game 2",
        player_count: 5,
        won: true
      },
      {
        title: "Game 3",
        player_count: 2,
        won: false
      }
    ]
  end
end
