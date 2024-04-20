# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:pay]

  def index
    @selected_league = determine_league current_user, params[:league_id]
    return unless @selected_league

    @entries = @selected_league.entries.where(user: current_user)
  end

  def buy
    league = determine_league current_user, params[:league_id]

    # Create the entries
    success = 0
    errors = 0
    error = ''
    params[:quantity].to_i.times do
      entry = Entry.new(user: current_user, league:)
      if entry.save
        success += 1
      else
        errors += 1
        error = entry.errors[:base].join(', ')
      end
    end

    if success && !errors
      message = "You successfully purchased #{success} #{'entry'.pluralize(success)}. Good luck!"
    elsif success && errors
      message = "Partial success! You have purchased #{success} #{entry.pluralize success} but you cannot purchase "
      "more. #{error}"
    else
      message = "Unable to purchase entries. #{error}"
    end
    redirect_to league_entries_path(league), notice: message
  end

  def pay
    entry = Entry.find(params[:id])
    if entry.paid_at.nil?
      entry.paid_at = Time.now
      entry.save
    end
    redirect_to standings_path, notice: 'Entry is now marked paid.'
  end
end
