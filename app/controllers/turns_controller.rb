class TurnsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    turn = build_turn(game)
    apply_turn(game, turn) if turn.valid?
    redirect_to game_path(game)
  end

  private

  def build_turn(game)
    attrs = turn_params(game).merge(user_id: Current.session.user.id, game_id: game.id)
    game.turn_class.new(attrs)
  end

  def apply_turn(game, turn)
    result = game.play_turn(turn)
    game.advance_turn unless result.go_again?
    game.save!
    game.declare_winner_if_over!
  end

  def turn_params(game)
    params.expect(turn: game.turn_params_keys)
  end
end
