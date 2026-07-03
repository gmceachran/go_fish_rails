class GamesController < ApplicationController
  def index
    @user_games = Current.session.user.games
    @open_games = Game.waiting - @user_games
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(params.require(:game).permit(:max_players))
    @game.save
    @game.players.create(user: Current.session.user)
    redirect_to root_path
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
