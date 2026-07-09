class WinnersController < ApplicationController
  def show
    @winner_name = Game.find(params[:id]).go_fish.winner.name
    render layout: "application_no_sidebar"
  end
end
