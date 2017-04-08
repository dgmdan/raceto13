class StandingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @entries = []

    # Parse all entries and hits
    entries = Entry.all
    entries.each do |entry|
      entry_minimal = {
          id: entry.id,
          name: entry.user.name,
          team_name: entry.team ? entry.team.name : 'Pending',
          team_data_name: entry.team ? entry.team.data_name : '',
          runs: entry.hits.select('runs, hit_on, game_id'),
          run_count: entry.hits.count,
          won_at: entry.won_at,
          won_place: entry.won_place,
          paid_at: entry.paid_at,
          games_played: entry.game_count ? entry.game_count : entry.team.games.count,
          gravatar_url: entry.user.gravatar_url
      }
      @entries << entry_minimal
    end

    # Sort by winners, then run count (descending), then games played (ascending)
    @entries.sort_by! { |e| [e[:won_place] || 99, -e[:run_count], e[:games_played]] }

    # Figure out rankings
    current_rank, current_runs, current_games_played = nil, nil, nil
    @entries.each do |entry|
      if current_rank.nil? || current_runs != entry[:run_count] || current_games_played != entry[:games_played]
        current_rank = current_rank.nil? ? 1 : (current_rank + 1)
        current_runs = entry[:run_count]
        current_games_played = entry[:games_played]
      end
      entry[:rank] = current_rank
    end
  end

end
