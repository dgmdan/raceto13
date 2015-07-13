class LeaguesController < ApplicationController
  before_action :authenticate_admin!, except: [:join]
  before_action :authenticate_user!, only: [:join]
  before_action :set_league, only: [:show, :edit, :update, :destroy, :join, :update_teams, :mass_email]

  # GET /leagues
  # GET /leagues.json
  def index
    @leagues = League.all
  end

  # GET /leagues/1
  # GET /leagues/1.json
  def show
    @teams = Team.order('name')
    # @my_teams = current_user.team_users.where(league: @league, team_id: params[:team_id])
  end

  # GET /leagues/new
  def new
    @league = League.new
  end

  # GET /leagues/1/edit
  def edit
  end

  # POST /leagues
  # POST /leagues.json
  def create
    @league = League.new(league_params)
    @league.user_id = current_user.id

    respond_to do |format|
      if @league.save
        format.html { redirect_to leagues_path, notice: 'League was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /leagues/1
  # PATCH/PUT /leagues/1.json
  def update
    respond_to do |format|
      if @league.update(league_params)
        format.html { redirect_to leagues_path, notice: 'League was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /leagues/1
  # DELETE /leagues/1.json
  def destroy
    @league.destroy
    respond_to do |format|
      format.html { redirect_to leagues_url, notice: 'League was successfully destroyed.' }
    end
  end

  def mass_email
    if request.post?
      users = @league.users
      subject = params[:post][:subject]
      body = params[:post][:body]
      users.each do |u|
        ActionMailer::Base.mail(from: 'MLB Runs Pool <runspool@danmadere.com>', to: u.email, subject: subject , body: body).deliver_now
      end
      redirect_to leagues_path, notice: "Your email '#{subject}' has been sent!"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_league
      @league = League.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def league_params
      params.require(:league).permit(:name, :starts_at)
    end
end
