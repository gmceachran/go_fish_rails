class GamesController < ApplicationController
  def index
    @user_games = Current.session.user.games.select { |game| game.state != "over" }
    # ASK: is the above the correct way to load this in?
    @open_games = Game.waiting - @user_games
  end

  def show
    # @game = Game.find(params[:id])
    # binding.irb
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

  # def destroy
  # end

  # def update
  # end

  def history
    @completed_games = Current.session.user.games.where(state: :over).order(ended_at: :desc)
  end
end

# game_path(:id)
