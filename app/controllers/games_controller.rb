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
    @completed_games = Current.session.user.games.where(state: :over).order(ended_at: :desc)
  end
end
