class TurnsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    turn = Turn.new(turn_params.merge(user_id: Current.session.user.id))

    game.play_turn(turn) if turn.valid?

    redirect_to game_path(game)
  end

  private

  def turn_params
    params.expect(turn: [ :rank, :opponent, :game_id ])
  end
end