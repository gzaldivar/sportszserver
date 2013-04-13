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
  end
  
  def create
    if (newsfeed = @sport.newsfeeds.create!(params[:newsfeed]))
       
      respond_to do |format|
        format.html { redirect_to [@sport, newsfeed], notice: "News item created for #{@sport.sport_name}!" }
        format.json
        format.xml
      end
    else
      redirect_to :back, alert: "Error creating news item for #{@sport.sport_name}"
    end
  end
  
  def show
  end
  
  def index
    if (!params[:team].nil? and !params[:team][:id].blank?)
      @newsfeed = @sport.newsfeeds.where(team: params[:team][:id].to_s).limit(20).desc(:updated_at)
    elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
      @newsfeed = @sport.newsfeeds.where(athlete: params[:athlete][:id].to_s).limit(20).desc(:updated_at)
    elsif !params[:coach].nil? and !params[:coach][:id].blank?
      @newsfeed = @sport.newsfeeds.where(coach: params[:coach][:id].to_s).limit(20).desc(:updated_at)
    elsif !params[:player].nil? and !params[:player].blank?
      @newsfeed = @sport.newsfeeds.where(athlete: params[:player].to_s).limit(20).desc(:updated_at)
    elsif !params[:teamname].nil? and !params[:teamname].blank?
      @newsfeed = @sport.newsfeeds.where(team: params[:teamname].to_s).limit(20).desc(:updated_at)
    elsif !params[:coachname].nil? and !params[:coachname].blank?
      @newsfeed = @sport.newsfeeds.where(coach: params[:coachname].to_s).limit(20).desc(:updated_at)      
    else
      @newsfeed = @sport.newsfeeds.limit(40).desc(:updated_at)
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
    @athletes = @sport.athletes
    @coaches = @sport.coaches
    @teams = @sport.teams
  end
  
  def update
    if @newsfeed.update_attributes(params[:newsfeed])
      redirect_to [@sport, @newsfeed], notice: "Update sucessful!"
    else
      redirect_to :back, alert: "Error updating news feed item."
    end
  end
  
  def destroy
    if @newsfeed.delete
      redirect_to :back, notice: "News item delete successful!"
    else
      redirect_to :back, alert: "Error deleting news item"
    end
  end
  
  private
  
    def get_sport
      @sport = Sport.find(params[:sport_id])
    end
    
    def correct_feeditem
      @newsfeed = @sport.newsfeeds.find(params[:id])
    end
  
end
