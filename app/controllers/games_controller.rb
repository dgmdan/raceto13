class GamesController < ApplicationController
  before_action :authenticate_admin!
  # before_action :set_game, only: [:show, :edit, :update, :destroy]

  def index
    if params[:date]
      @games = Game.where(started_on: params[:date])
    else
      @games = Game.order(:started_on)
    end
    @games = @games.paginate(page: params[:page])
  end

  def mass_entry
    if request.post?
      rejected = Array.new
      15.times do |count|
        unless params[count.to_s]['home_team'].blank?
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
      end
      redirect_to mass_entry_games_path, notice: 'Games created. Rejects: ' + rejected.to_s
    end
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
