class NewsfeedsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_sport
  before_filter :correct_feeditem,      only: [:edit, :update, :destroy, :show]
  
  def new
    @newsfeed = Newsfeed.new
    @athletes = @sport.athletes
    @coaches = @sport.coaches
    @teams = @sport.teams
    @schedules = []
  end
  
  def create
    begin
      newsfeed = @sport.newsfeeds.create!(params[:newsfeed])
       
      respond_to do |format|
        format.html { redirect_to [@sport, newsfeed], notice: "News item created for #{@sport.sport_name}!" }
        format.json { render json: { newsfeed: newsfeed, request: sport_newsfeed_url(@sport, newsfeed) } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error creating news item for #{@sport.sport_name}" }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end
  end
  
  def show
  end
  
  def index
    if (!params[:team].nil? and !params[:team][:id].blank?)
      @newsfeeds = @sport.newsfeeds.where(team: params[:team][:id].to_s).limit(20).desc(:updated_at)
    elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
      @newsfeeds = @sport.newsfeeds.where(athlete: params[:athlete][:id].to_s).limit(20).desc(:updated_at)
    elsif !params[:coach].nil? and !params[:coach][:id].blank?
      @newsfeeds = @sport.newsfeeds.where(coach: params[:coach][:id].to_s).limit(20).desc(:updated_at)
    elsif !params[:player].nil? and !params[:player].blank?
      @newsfeeds = @sport.newsfeeds.where(athlete: params[:player].to_s).limit(20).desc(:updated_at)
    elsif !params[:teamname].nil? and !params[:teamname].blank?
      @newsfeeds = @sport.newsfeeds.where(team: params[:teamname].to_s).limit(20).desc(:updated_at)
    elsif !params[:coachname].nil? and !params[:coachname].blank?
      @newsfeeds = @sport.newsfeeds.where(coach: params[:coachname].to_s).limit(20).desc(:updated_at)      
    else
      @newsfeeds = @sport.newsfeeds.limit(40).desc(:updated_at)
    end
    
    @coaches = @sport.coaches
    @athletes = @sport.athletes
    
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
  end
  
  def edit
    @teams = @sport.teams
    if !@newsfeed.team.nil? and !@newsfeed.team.blank?
      @athletes = @sport.athletes.where(team: @newsfeed.team).entries
      @coaches = @sport.coaches.where(team: @newsfeed.team).entries
      @schedules = @sport.teams.find(@newsfeed.team).gameschedules.asc(:gamedate).entries
    else
      @athletes = @sport.athletes
      @coaches = @sport.coaches
      @schedules = []
    end
  end
  
  def update
    begin
      @newsfeed.update_attributes!(params[:newsfeed])
      respond_to do |format|
        format.html { redirect_to [@sport, @newsfeed], notice: "Update sucessful!" }
        format.json { render json: { newsfeed: @newsfeed, request: [@sport, @newsfeed] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error updating news feed item." }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end
  end
  
  def destroy
    begin
      @newsfeed.delete
      respond_to do |format|
        format.html { redirect_to :back, notice: "News item delete successful!" }
        format.json { render json: { success: "success", request: @sport } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error deleting news item" }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end
  end
  
  def updateteams
      @gameschedules = @sport.teams.find(params[:teamid]).gameschedules
      @athletes = @sport.athletes.where(team: params[:teamid].to_s).entries
      @coaches = @sport.coaches.where(team: params[:teamid].to_s).entries
  end


  private
  
    def get_sport
      @sport = Sport.find(params[:sport_id])
    end
    
    def correct_feeditem
      @newsfeed = @sport.newsfeeds.find(params[:id])
    end
  
end
