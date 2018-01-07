class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:pay]

  def index
    @selected_league = determine_league(current_user, params[:league_id])
    @entries = @selected_league.entries.where(user: current_user)
  end

  def buy
    @league = League.joins(:users).where('users.id': current_user.id, id: params[:league_id]).first

    # Create the entries
    success = 0
    errors = 0
    error = ''
    params[:quantity].to_i.times do
      entry = Entry.new(user: current_user, league_id: params[:league_id])
      if entry.save
        success += 1
      else
        errors += 1
        error = entry.errors[:base].join(', ')
      end
    end

    # TODO: email a confirmation

    if success > 0 && errors == 0
      message = "You successfully purchased #{success} " + 'entry'.pluralize(success) + ". Good luck!"
    elsif success > 0 && errors > 0
      message = "Partial success! You have purchased #{success} " + 'entry'.pluralize(success) + " but you cannot purchase more. #{error}"
    else
      message = "Unable to purchase entries. #{error}"
    end

    redirect_to league_entries_path(@league.id), notice: message
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
