class PlayersController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @player = @game.players.new(user: Current.session.user)
    @player.save
    redirect_to root_path
  end
end
