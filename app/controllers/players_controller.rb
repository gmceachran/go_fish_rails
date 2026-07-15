class PlayersController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    @player = @game.players.new(user: Current.session.user)
    if @player.save
      Turbo::StreamsChannel.broadcast_replace_later_to(
        @game,
        target: "game_#{@game.id}_player_count",
        partial: "games/user_game",
        locals: { user_game: @game.reload }
      )

      redirect_to root_path
    end
  end
end
