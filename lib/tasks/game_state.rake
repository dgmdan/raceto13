# frozen_string_literal: true

require 'game_state'

namespace :game_state do
  desc 'Assign a team to each unassigned entry'
  task assign_teams: :environment do
    entries = Entry.unassigned
    entries.each do |entry|
      entry.team = entry.league.available_teams.sample
      entry.save
    end
  end

  desc 'Create hits based on existing games for one date'
  task :create_hits, [:query_date] => [:environment] do |_t, args|
    GameState.create_hits!(args.query_date)
  end

  desc 'Reset the games, hits and won_at column on entries'
  task reset: :environment do
    GameState.reset!
  end

  desc 'Reset the games and hits for 2015 season'
  task reset_all_scores: :environment do
    GameState.reset_all_scores!
  end

  desc 'Give everyone the default notification types'
  task assign_notifications: :environment do
    NotificationType.all.each do |notification_type|
      User.all.each do |user|
        NotificationTypeUser.find_or_create_by(user:, notification_type:)
      end
    end
  end

  desc 'Simulate the 2014 season'
  task simulate2014: :environment do
    WebMock.allow_net_connect!
    GameState.reset!
    start_date = Date.parse('2014-03-22')
    end_date = Date.parse('2014-09-28')
    (start_date..end_date).each do |date|
      GameState.scrape_games!(date)
    end
  end

  desc 'Simulate the 2016 season'
  task simulate2016: :environment do
    GameState.reset!
    league = League.find_by(id: 1)
    start_date = league.starts_at.to_date
    end_date = league.ends_at.to_date
    (start_date..end_date).each do |date|
      GameState.scrape_games!(date)
    end
  end
end
