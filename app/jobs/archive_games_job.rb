class ArchiveGamesJob < ApplicationJob
  queue_as :default

  def perform(game)
    game_record = Game.find(game.id)
    game_record.update(archived_at: Time.current)
  end
end
