class GamesController < ApplicationController
  def index
    @user_games = Current.session.user.games.not_over
    @open_games = Game.waiting - @user_games
  end

  def show
    @game_id = params[:id]
    game_model = Game.find(@game_id)

    if game_model.save
      return redirect_to game_winner_path(game.winner.user_id) if game_model.over?

      game = game_model.game_state
      user_id = Current.session[:user_id]
      @is_clients_turn = game.active_player?(user_id)
      @opponents = game.opponents
      @player = game.player(user_id)
      @turn = Turn.new

      render layout: "application_no_sidebar"
    else
      redirect_to root_path, warning: "That game does not exist."
    end
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(params.require(:game).permit(:max_players, :type))
    @game.save
    @game.players.create(user: Current.session.user)
    redirect_to root_path
  end

  def history
    @completed_games = Current.session.user.games.where(state: :over).order(ended_at: :desc)
  end
end
