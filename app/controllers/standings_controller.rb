class StandingsController < ApplicationController
  def index
    @entries = []

    # Parse all entries and hits
    entries = Entry.all
    entries.each do |entry|
      entry_minimal = {
          name: entry.user.name,
          team_name: entry.team.name,
          team_data_name: entry.team.data_name,
          runs: entry.hits.collect{ |h| h.runs },
          run_count: entry.hits.count,
          won_at: entry.won_at
      }
      @entries << entry_minimal
    end

    # Sort by highest run count
    @entries.sort_by! { |e| e[:run_count] }
    @entries.reverse!

    @run_counts = @entries.map{ |e| e[:run_count] }.uniq.sort.reverse
  end
end
