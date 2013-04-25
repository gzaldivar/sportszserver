class SportsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :correct_sport,         only: [:show, :edit, :update, :destroy, :sport_user_alerts]
   
  def new
    @sport = Sport.new
    @sport.teams.build
  end
  
  def create
    begin
      @sport = current_site.sports.build(params[:sport])
      if !@sport.sportname.blank?
         @sport.name = @sport.sportname
        @sport.has_stats = true
      end
      @sport.save!
      redirect_to @sport
    rescue Exception => e
      redirect_to :back, alert: "Error saving sport information " + e.message
    end
  end
  
  def show
    @newsfeed = @sport.newsfeeds.limit(10).desc(:updated_at)
    @athletes = @sport.athletes
    @followed = []
    if signed_in?
      cnt = 0
      @athletes.each do |a|
        if a.followers.has_key?(current_user.id.to_s)
          @followed[cnt] = a
          cnt+=1
        end
      end
    end
    
    respond_to do |format|
      format.html
#      format.json {  render status: 200, json: { id: @sport.id , season: @sport.season, name: @sport.name, sex: @sport.sex, teams: @sport.teams} }
      format.json 
     end
  end
  
  def index
    @sports = []
    if !params[:site].blank?
      Sport.where(site_id: params[:site]).each_with_index do |s, cnt|
        @sports[cnt] = s
      end
    else
      redirect_to :back, alert: "No site parameter"
    end
    
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
  end
  
  def update
    begin
      @sport.update_attributes(params[:sport])
      redirect_to @sport
    rescue Exception => e
      redirect_to :back, alert: "Error updating sport"
    end
  end
  
  def destroy
    deletesport(@sport)
    @sport.destroy
    redirect_to current_site
  end
  
  def feed
    if params[:sport]
      @newsfeed = get_sport_news(Sport.find(params[:sport]))
    elsif params[:athlete]
      @athlete = params[:athlete]
      @newsfeed = get_athlete_news(Athlete.find(params[:athlete]))
    elsif params[:team]
      @team = params[:team]
      @newsfeed = get_team_news(@sport.id, params[:team])
    end
  end

  def sport_user_alerts
    @alerts = @sport.alerts.where(user_id: params[:user_id]).entries
    respond_to :json
  end

  private
  
    def correct_sport
      @sport = Sport.find(params[:id])
    end
  
end
