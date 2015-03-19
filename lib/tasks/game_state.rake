namespace :game_state do

  desc "Assign a team to each unassigned entry"
  task assign_teams: :environment do
    entries = Entry.unassigned
    entries.each do |entry|
      entry.team = entry.league.available_teams.sample
      entry.save
    end
  end

  desc "Reset the games, hits and won_at column on entries"
  task reset: :environment do
    Game.destroy_all
    Hit.destroy_all
    Entry.where.not(won_at: nil).each do |entry|
      entry.won_at = nil
      entry.save
    end
  end
end
