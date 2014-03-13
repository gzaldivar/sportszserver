class NewsfeedsController < ApplicationController
  before_filter :authenticate_user!,    only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_sport
  before_filter :correct_feeditem,      only: [:edit, :update, :destroy, :show, :updatephoto]
  
  def new
    @newsfeed = Newsfeed.new
    @athletes = @sport.athletes.asc(:number)
    @coaches = @sport.coaches
    @teams = @sport.teams
    if current_team?
      @schedules = current_team.gameschedules.asc(:gamedate)
    else
      @schedules = []
    end
  end
  
  def create
    begin
      newsfeed = @sport.newsfeeds.create!(params[:newsfeed])
       
      respond_to do |format|
        format.html { redirect_to [@sport, newsfeed], notice: "News item created for #{@sport.sport_name}!" }
        format.json { render json: { newsfeed: newsfeed } }
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
      @newsfeeds = @sport.newsfeeds.where(team: params[:team][:id].to_s).or({team_id: ""}, {team_id: nil}).limit(40).desc(:updated_at).paginate(:page=>params[:page])
    elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
      @newsfeeds = @sport.newsfeeds.where(athlete: params[:athlete][:id].to_s).limit(40).desc(:updated_at).paginate(:page=>params[:page])
    elsif !params[:coach].nil? and !params[:coach][:id].blank?
      @newsfeeds = @sport.newsfeeds.where(coach: params[:coach][:id].to_s).limit(40).desc(:updated_at).paginate(:page=>params[:page])
    elsif !params[:player].nil? and !params[:player].blank?
      @newsfeeds = @sport.newsfeeds.where(athlete: params[:player].to_s).limit(40).desc(:updated_at).paginate(:page=>params[:page])
    elsif !params[:teamname].nil? and !params[:teamname].blank?
      @newsfeeds = @sport.newsfeeds.where(team: params[:teamname].to_s).limit(40).desc(:updated_at).paginate(:page=>params[:page])
    elsif !params[:coachname].nil? and !params[:coachname].blank?
      @newsfeeds = @sport.newsfeeds.where(coach: params[:coachname].to_s).limit(40).desc(:updated_at).paginate(:page=>params[:page])
    elsif !params[:team_id].nil?
      @newsfeeds = @sport.newsfeeds.where(team_id: params[:team_id].to_s).limit(40).desc(:updated_at).paginate(:page => params[:page])
    else
      @newsfeeds = @sport.newsfeeds.limit(40).desc(:updated_at).paginate(:page=>params[:page])
    end
    
    @newsfeeds.each do |n|
      puts n.team_id
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

    if !@newsfeed.team_id.nil? and !@newsfeed.team_id.blank? or current_team?
      @athletes = @sport.athletes.where(team_id: @newsfeed.team_id).asc(:number)
      @coaches = @sport.coaches.where(team_id: @newsfeed.team_id)
      if current_team?
        puts "using current team"
        @schedules = current_team.gameschedules.asc(:gamedate)
      else 
        puts "using news feed team id"
        @schedules = @sport.teams.find(@newsfeed.team_id).gameschedules.asc(:gamedate)
      end
    else
      @athletes = @sport.athletes
      @coaches = @sport.coaches
      @schedules = []
    end
  end
  
  def update
#    begin
      @newsfeed.update_attributes!(params[:newsfeed])
      respond_to do |format|
        format.html { redirect_to [@sport, @newsfeed], notice: "Update sucessful!" }
        format.json { render json: { newsfeed: @newsfeed } }
      end
#    rescue Exception => e
#      respond_to do |format|
#        format.html { redirect_to :back, alert: "Error updating news feed item." }
#        format.json { render status: 404, json: { error: e.message, request: @sport } }
#      end
#    end
  end
  
  def destroy
    begin
      @newsfeed.destroy
      respond_to do |format|
        format.html { redirect_to sport_path(@sport), notice: "News item delete successful!" }
        format.json { render json: { success: "success", request: @sport } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to sport_path(@sport), alert: "Error deleting news item" }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end
  end
  
  def updateteams
      @gameschedules = @sport.teams.find(params[:teamid]).gameschedules
      @athletes = @sport.athletes.where(team: params[:teamid].to_s).entries
      @coaches = @sport.coaches.where(team: params[:teamid].to_s).entries
  end

  def createphoto
    begin
      path = CGI.unescape(params[:filepath]).split('/')
      @newsfeed = @sport.newsfeeds.find(path[4])   
      path = params[:filepath].split('/')
      imagepath = CGI.unescape(path[2])
      @newsfeed.processing = true

      @newsfeed.save!

      queue = @sport.photo_queues.new(modelid: @newsfeed.id, modelname: "newsfeeds", filename: params[:filename], filetype: params[:filetype], filepath: imagepath)
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end
    rescue Exception => e
      puts e.message
    end
  end

  def updatephoto
    begin    
      @newsfeed.processing = true

      @newsfeed.save!

      queue = @sport.photo_queues.new(modelid: @newsfeed.id, modelname: "newsfeeds", filename: params[:filename], filetype: params[:filetype], 
                                      filepath: params[:filepath])
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end

      respond_to do |format|
        format.json { render json: { success: "success", newsfeed: @newsfeed } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message, newsfeed: @newsfeed } }
      end
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
