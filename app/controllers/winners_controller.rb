class WinnersController < ApplicationController
  def show
    @winner_name = Game.find(params[:id]).game_state.winner.name
    render layout: "application_no_sidebar"
  end
end
