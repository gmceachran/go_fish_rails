include FactoryBot::Syntax::Methods

puts "Seeding the database..."

Game.destroy_all
User.destroy_all

create :user,
       email_address: "dev@example.com",
       password: "password"

create :game, :with_players
