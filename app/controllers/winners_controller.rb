class WinnersController < ApplicationController
  def show
    game = Game.find(params[:game_id])
    @winner_name = game.players.find_by(winner: true).user.email_address
    render layout: "application_no_sidebar"
  end
end
