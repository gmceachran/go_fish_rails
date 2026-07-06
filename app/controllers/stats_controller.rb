class StatsController < ApplicationController
  def index
    @games_played = Current.session.user.games_played_count
    @games_won = Current.session.user.games_won_count
    @win_percentage = Current.session.user.win_percentage
  end
end
