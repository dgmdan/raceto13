class LeaguesController < ApplicationController
  before_action :authenticate_admin!, only: [:show, :edit, :update, :destroy, :mass_email]
  before_action :authenticate_user!, only: [:index, :new, :create]

  # GET /leagues
  # GET /leagues.json
  def index
    @leagues = current_user.owned_leagues
  end

  # GET /leagues/1
  # GET /leagues/1.json
  def show
    @league = League.find(params[:id])
    @teams = Team.order('name')
    # @my_teams = current_user.team_users.where(league: @league, team_id: params[:team_id])
  end

  # GET /leagues/new
  def new
    @league = League.new
  end

  # GET /leagues/1/edit
  def edit
    @league = League.find(params[:id])
  end

  # POST /leagues
  # POST /leagues.json
  def create
    @league = League.new(league_params)
    @league.user_id = current_user.id

    respond_to do |format|
      if @league.save
        LeagueUser.create!(user: current_user, league: @league)
        format.html { redirect_to leagues_path, notice: 'League was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /leagues/1
  # PATCH/PUT /leagues/1.json
  def update
    @league = League.find(params[:id])
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
    league = League.find(params[:id])
    league.destroy
    respond_to do |format|
      format.html { redirect_to leagues_url, notice: 'League was successfully destroyed.' }
    end
  end

  def mass_email
    @league = League.find(params[:id])
    if request.post?
      subject = params[:post][:subject]
      body = params[:post][:body]
      to = User.all.map { |x| x.email }.uniq
      ActionMailer::Base.mail(from: 'Race To 13 <bot@raceto13.com>', to: 'bot@raceto13.com', bcc: to, subject: subject, body: body).deliver_later
      redirect_to leagues_path, notice: "Your email '#{subject}' has been sent!"
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def league_params
      params.require(:league).permit(:name, :starts_at, :ends_at)
    end
end
