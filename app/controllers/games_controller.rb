# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :authenticate_admin!, only: %i[edit update destroy mass_entry]
  before_action :authenticate_user!, only: %i[index show]
  # before_action :set_game, only: [:show, :edit, :update, :destroy]

  def index
    @games = if params[:date]
               Game.where(started_on: params[:date])
             else
               Game.order(:started_on)
             end
    @games = @games.paginate(page: params[:page])
  end

  def show
    @game = Game.find_by(id: params[:id])
  end

  def mass_entry
    return unless request.post?

    rejected = []
    15.times do |count|
      next if params[count.to_s]['home_team'].blank?

      home_team = Team.find_by_data_name(params[count.to_s]['home_team'])
      away_team = Team.find_by_data_name(params[count.to_s]['away_team'])
      if home_team && away_team
        game = Game.new
        game.home_team = home_team
        game.away_team = away_team
        game.home_score = params[count.to_s]['home_score']
        game.away_score = params[count.to_s]['away_score']
        game.started_on = params['game']['date']
        rejected << params[count.to_s]['away_team'] unless game.save
      else
        rejected << params[count.to_s]['away_team']
      end
    end
    redirect_to mass_entry_games_path, notice: "Games created. Rejects: #{rejected}"
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def game_params
  #   params.require(:game).permit(:home_team_id, :away_team_id, :home_score, :away_score, :started_on)
  # end
end
