class GamesController < ApplicationController
  def index
  end

  def index
    @open_games = Game.waiting
    @user_games = Current.session.user.games
  end

  def create
    @game = Game.new(max_players: params[:options])
    if @game.save
      Current.session.user.players.create!(game: @game)
      # redirect_to ?
    else
      redirect_to root_path
    end
  end

  def destroy
  end

  def update
  end

  def history
    @game_history = [
      { title: "Game 1", player_count: 3, won: false },
      { title: "Game 2", player_count: 5, won: true },
      { title: "Game 3", player_count: 2, won: false }
    ]
  end
end
