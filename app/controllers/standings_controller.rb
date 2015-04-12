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
          runs: entry.hits.to_a.each_with_object({}){ |c,h| h[c.runs] = c.hit_on },
          run_count: entry.hits.count,
          won_at: entry.won_at,
          paid_at: entry.paid_at
      }
      @entries << entry_minimal
    end

    # Sort by highest run count
    @entries.sort_by! { |e| e[:run_count] }
    @entries.reverse!

    @run_counts = @entries.map{ |e| e[:run_count] }.uniq.sort.reverse
  end

end
