class EntriesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @entries = current_user.entries
  end

  def buy
    @league = League.first

    # Create the entries
    success = 0
    errors = 0
    error = ''
    params[:quantity].to_i.times do
      entry = Entry.new(user: current_user, league: @league)
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

    redirect_to entries_path, notice: message
  end
end