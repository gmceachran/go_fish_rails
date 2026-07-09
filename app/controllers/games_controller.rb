class GamesController < ApplicationController
  def index
    @user_games = Current.session.user.games.not_over
    @open_games = Game.waiting - @user_games
  end

  def show
    @game_id = params[:id]
    user_id = Current.session[:user_id]
    game = Game.find(@game_id).go_fish
    @is_clients_turn = game.active_player?(user_id)
    @opponents = game.opponents
    @player = game.player(user_id)
    @turn = Turn.new

    render layout: "application_no_sidebar"
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

  def history
    @completed_games = Current.session.user.games.where(state: :over).order(ended_at: :desc)
  end
end
