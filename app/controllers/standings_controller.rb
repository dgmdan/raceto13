# frozen_string_literal: true

class StandingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @entries = []

    @selected_league = determine_league(current_user, params[:league_id])

    # Parse all entries and hits
    return unless @selected_league

    entries = @selected_league.entries
    entries.each do |entry|
      game_count = if entry.game_count
                     entry.game_count
                   elsif entry.team
                     entry.team.games.count
                   else
                     0
                   end
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
        games_played: game_count,
        gravatar_url: entry.user.gravatar_url
      }

      # add the "highest miss" for each entry. used in sorting.
      (0..13).each do |i|
        runs = 13 - i
        if entry.hits.where(runs:).none?
          entry_minimal[:highest_miss] = runs
          break
        end
      end
      @entries << entry_minimal
    end

    # Sort by winners, then run count (descending), then games played (ascending), then highest miss (ascending)
    @entries.sort_by! { |e| [e[:won_place] || 99, -e[:run_count], e[:games_played], e[:highest_miss]] }

    # Figure out rankings
    current_rank = nil
    current_runs = nil
    current_games_played = nil
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
