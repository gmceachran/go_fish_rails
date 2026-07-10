class TurnsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    turn = Turn.new(turn_params.merge(user_id: Current.session.user.id, game_id: game.id))

    if turn.valid?
      result = game.play_turn(turn)
      game.game_state.advance_turn unless result.go_again
      game.save!
    end

    redirect_to game_path(game)
  end

  private

  def turn_params
    params.expect(turn: [ :rank, :opponent ])
  end
end
