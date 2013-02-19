class SportsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :correct_sport,         only: [:show, :edit, :update, :destroy]
   
  def new
    @sport = Sport.new
    @sport.teams.build
  end
  
  def create
    @sport =  current_site.sports.build(params[:sport])      
    if @sport.save
      redirect_to @sport
    else
      flash[:error] = "Error saving sport information"
      redirect_to :back
    end
  end
  
  def show
    @newsfeed = @sport.newsfeeds.limit(10).asc(:updated_at)
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
      format.xml
      format.json 
      format.js
    end
  end
  
  def index
    @sports = []
    if !params[:site].blank?
      Sport.where(site_id: params[:site]).each_with_index do |s, cnt|
        @sports[cnt] = s
      end
    else
      flash[:error] = "No site parameter"
      redirect_to :back
    end
    
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
  end
  
  def update
    if @sport.update_attributes(params[:sport])
      redirect_to @sport
    else
      flash[:error] = "Error updating sport"
      redirect_to :back
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

  private
  
    def correct_sport
      @sport = Sport.find(params[:id])
    end
  
end
