class TurnsController < ApplicationController
  def create
    game = Game.find(params[:game_id])

    case game
    when GoFishGame then handle_go_fish_turn(game)
    when CrazyEightsGame then handle_crazy_eights_turn(game)
    end

    redirect_to game_path(game)
  end

  private

  def handle_go_fish_turn(game)
    turn = Turn.new(turn_params.merge(user_id: Current.session.user.id, game_id: game.id))
    return unless turn.valid?

    apply_go_fish_turn(game, turn)
  end

  def apply_go_fish_turn(game, turn)
    result = game.play_turn(turn)
    game.game_state.advance_turn unless result.go_again
    game.save!
  end

  def handle_crazy_eights_turn(game)
    turn = build_crazy_eights_turn(game)
    return unless turn.valid?

    apply_crazy_eights_turn(game, turn)
  end

  def build_crazy_eights_turn(game)
    attrs = crazy_eights_turn_params.merge(user_id: Current.session.user.id, game_id: game.id)
    CrazyEightsTurn.new(attrs)
  end

  def apply_crazy_eights_turn(game, turn)
    result = game.play_turn(turn)
    game.game_state.advance_turn unless result.play_again
    game.save!
    declare_crazy_eights_winner(game)
  end

  def declare_crazy_eights_winner(game)
    winner = game.game_state.winner
    return unless winner

    player = game.players.find_by(user_id: winner.user_id)
    game.declare_winner!(player)
  end

  def turn_params
    params.expect(turn: [ :rank, :opponent ])
  end

  def crazy_eights_turn_params
    params.expect(turn: [ :rank, :suit, :action ])
  end
end
