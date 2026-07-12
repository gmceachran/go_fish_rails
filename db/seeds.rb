include FactoryBot::Syntax::Methods

puts "Seeding the database..."

Game.destroy_all
User.destroy_all

dev = create :user,
             email_address: "dev@example.com",
             password: "password"

opponent = create :user,
           email_address: "opponent@example.com",
           password: "password"

waiting_game = create :game
waiting_game.players.create!(user: dev)

active_game = create :game, max_players: 2
active_game.players.create!(user: dev)
active_game.players.create!(user: opponent)

won_game = create :game, max_players: 2
winning_player = won_game.players.create!(user: dev)
won_game.players.create!(user: opponent)
won_game.declare_winner!(winning_player)

lost_game = create :game, max_players: 2
lost_game.players.create!(user: dev)
losing_opponent_as_winner = lost_game.players.create!(user: opponent)
lost_game.declare_winner!(losing_opponent_as_winner)

another_opponent = create :user, email_address: "opponent2@example.com"
another_lost_game = create :game, max_players: 2
another_lost_game.players.create!(user: dev)
another_winner = another_lost_game.players.create!(user: another_opponent)
another_lost_game.declare_winner!(another_winner)

create :game, :with_players, max_players: 2
create :game
