Rails.application.configure do
  config.good_job.cron = { example: { cron: "@hourly", class: "ArchiveGamesJob"  } }
end
