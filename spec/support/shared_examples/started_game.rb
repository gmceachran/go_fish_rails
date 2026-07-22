RSpec.shared_examples "a game that starts when full" do |classes|
  let(:engine_class) { classes.fetch(:engine_class) }
  let(:player_class) { classes.fetch(:player_class) }
  let(:started_state) { Game.find(game.id).game_state }

  it "exposes the declared engine_class and player_class" do
    expect(game.engine_class).to eq engine_class
    expect(game.player_class).to eq player_class
  end

  it "transitions to active and sets started_at" do
    expect(game.reload.state).to eq "active"
    expect(game.started_at).not_to be_nil
  end

  it "builds game_state as the declared engine_class" do
    expect(started_state).to be_a_kind_of engine_class
  end

  it "maps join players to the declared player_class in join order" do
    expect(started_state.players).to all be_a player_class
    expect(started_state.players.map(&:user_id)).to eq [ player1.user_id, player2.user_id ]
  end
end

RSpec.shared_examples "a game that stays waiting until full" do
  it "stays waiting without persisting game state" do
    game.reload
    expect(game.state).to eq "waiting"
    expect(game.started_at).to be_nil
    expect(game.game_state).to be_nil
  end
end
