class ArchiveGamesJob < ApplicationJob
  queue_as :default

  def perform
    game_records = Game.where(state: :over) + Game.where("updated_at <= ?", 2.days.ago)
    game_records.filter! { |game_record| game_record.archived_at.nil? }

    game_records.each do |game_record|
      game_record.update archived_at: Time.current
    end
  end
end
