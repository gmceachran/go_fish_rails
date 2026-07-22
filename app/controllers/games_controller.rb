class GamesController < ApplicationController
  def index
    @user_games = Current.session.user.games.not_over
    @open_games = Game.waiting - @user_games
  end

  def show
    @game_model = Game.find(params[:id])
    @winner = @game_model.players.find_by(winner: true) if @game_model.over?
    @board = @game_model.game_state.board_for(user_id: Current.session[:user_id],
                                              game_id: @game_model.id)
    render layout: "application_no_sidebar"
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
