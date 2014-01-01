class SportsController < ApplicationController
  before_filter :authenticate_user!,    only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:edit, :update, :destroy]
  before_filter :correct_sport,         only: [:show, :edit, :update, :destroy, :sport_user_alerts, :updatelogo, :displaynews, 
                                                :selectteam, :sortgamenews, :sortplayernews, :allnews, :featuredplayers, :selectfeaturedplayers,
                                                :showfeaturedplayers, :showfollowedplayers, :updateabout, :uploadabout, :clearabout]
   
  def new
    @sport = Sport.new
    @sport.teams.build
  end
  
  def create
    begin
      duplicate_user = Sport.find_by(adminid: current_user.id.to_s)

      if duplicate_user.nil?
        @sport = current_user.sports.build(params[:sport])
        @sport.city = @sport.zip.to_region(city: true)
        @sport.state = @sport.zip.to_region(state: true)
        @sport.contactemail = current_user.email
        @sport.adminid = current_user.id

        if !@sport.sportname.blank?
          @sport.name = @sport.sportname
          @sport.has_stats = true
        else
          @sport.sportname = @sport.name  # Keep capability to allow non stat sports. Mobile sends name not sportname
          @sport.has_stats = true
        end
        
        if @sport.beta?
          @sport.approved = false
        end

        if @sport.save!
          
          current_user.admin = true
          current_user.default_site = @sport.id
          current_user.tier = "Features"
          current_user.save

          respond_to do |format|
            format.html { redirect_to @sport, notice: "New Sport Site created!" }
            format.json { render json: { sport: @sport, request: @sport } }
          end
        else
          throw "User and email is already administering a site!"
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error saving sport information " + e.message }
        format.json { render status: 404, json: { error: e.message, request: current_user } }
      end
    end
  end
  
  def show
    site_visit(@sport)

    if @sport.teams.count == 1
      set_current_team(@sport.teams.first)
    end

    if signed_in? and current_user.admin and !current_site.approved?
      respond_to do |format|
        format.html { redirect_to approve_path }
        format.json
      end
    else
      if user_signed_in?
        @followed = @sport.athletes.where(fans: current_user.id).asc(:number)
      end

      if current_team?
        @schedules = @sport.teams.find(current_team.id).gameschedules.asc(:gamedate)
        @players = @sport.athletes.where(team_id: current_team.id).asc(:number)
        @newsfeeds = @sport.newsfeeds.where(team_id: current_team.id).desc(:updated_at).paginate(per_page: 10)

        if current_team.featuredplayers.nil?
          @featured = nil
        else
          @featured = @sport.athletes.where(team_id: current_team.id, :id.in => current_team.featuredplayers).asc(:number)
        end
      else
        @schedules = nil
        @players = nil
        @newsfeeds = @sport.newsfeeds.where(allsports: true).desc(:updated_at).paginate(per_page: 10)
      end

      if @newsfeeds.count > 0
        @thenews = @newsfeeds[0]
        puts @newsfeeds.count
      end

      if params[:photo_mode] == "photos"
        @photomode = "photos"
      else
        @photomode = "news"
      end
      
      respond_to do |format|
        format.html
        format.json 
       end
    end
  end
  
  def displaynews
    @thenews = @sport.newsfeeds.find(params[:newsitem_id])
    respond_to do |format|
      format.js
    end
  end

  def allnews
    @newsfeeds = @sport.newsfeeds.desc(:updated_at).paginate(:per_page => 10)
    respond_to do |format|
      format.js
    end
  end

  def sortgamenews
      @newsfeeds = @sport.newsfeeds.where(gameschedule_id: params[:game_id].to_s).desc(:updated_at).paginate(:per_page => 10)
   end

  def sortplayernews
        @newsfeeds = @sport.newsfeeds.where(athlete_id: params[:player_id].to_s).desc(:updated_at).paginate(:per_page => 10)
  end

  def selectteam
    set_current_team(@sport.teams.find(params[:team_id]))
#    redirect_to sport_path
  end

  def selectfeaturedplayers
    @players = @sport.athletes.where(team_id: current_team.id).asc(:number)
  end

  def featuredplayers
    if !params[:player_ids].nil?
        current_team.featuredplayers = Array.new

        params[:player_ids].each do |values|
          current_team.featuredplayers << values
        end

        if current_team.featuredplayers.count == 0
          current_team.featuredplayers = nil
        end
        
      current_team.save!
    end

    respond_to do |format|
      format.html { redirect_to sport_path(@sport), notice: "Featured players added!" }
      format.json { render status: 200, json: { success: "success" } }
    end
  end

  def showfeaturedplayers
    if current_team.featuredplayers.nil?
      @featured = nil
    else
      @featured = @sport.athletes.where(team_id: current_team.id, :id.in => current_team.featuredplayers).asc(:number)
    end
  end

  def showfollowedplayers
    @followed = @sport.athletes.where(fans: current_user.id).asc(:number)
  end

  def index
    if !params[:sport].nil? and !params[:sport].blank?
      thesport = params[:sport].to_s
    else
      thesport = "Football"   # Fix for forgetting to add this parameter to the football apps
    end

    @sports = find_a_sport(thesport)

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
      respond_to do |format|
        format.html { redirect_to @sport, notice: "Sport updated!" }
        format.json { render json: { sport: @sport, request: @sport } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error updating sport " + e.message }
        format.json { render status: 404, json: { error: e.message, request: current_user } }
      end
    end
  end
  
  def destroy
    begin
      deletesport(@sport)
      @sport.destroy
      respond_to do |format|
        format.html { redirect_to current_user }
        format.json { render json: { user: current_user, request: current_user } } 
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to current_user, alert: e.message }
        format.json { render status: 404, json: { error: e.message, request: current_user } } 
      end
    end
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
    if params[:updated_at]
      puts params[:updated_at]
      date = DateTime.parse(params[:updated_at]).utc
      puts date.to_s
      @alerts = @sport.alerts.where(user_id: params[:user_id].to_s, :updated_at.gt => date).desc(:created_at).entries
    else
      @alerts = @sport.alerts.where(user_id: params[:user_id].to_s).desc(:created_at).entries
    end
    respond_to :json
  end

  def home
    clear_site
    if user_signed_in? and current_site.nil? and current_user.default_site.nil?
      redirect_to new_sport_path
    elsif user_signed_in? and !current_user.default_site.nil?
      if !Sport.find(current_user.default_site).nil?
        redirect_to sport_path(id: current_user.default_site)
      else
        flash[:notice] = "Your default site no longer exists. Your admin may have created a new one or left our network. Use search below to find your site"
      end
    elsif user_signed_in?
      @admin_sites = []
      current_user.sports.each_with_index do |s, cnt|
        @admin_sites[cnt] = s
      end
      respond_to do |format|
        format.html
      end
    end
  end
  
  def about
  end

  def updateabout
  end

  def uploadabout
    @sport.update_attributes!(params[:sport])
    redirect_to about_sports_path(@sport)
  end

  def clearabout
    @sport.aboutsport = nil
    @sport.save!
    redirect_to about_sports_path(@sport)
  end

  def uploadpage
    if params[:page] == "About"
      if !params[:about_filename].blank?
        @sport.sitepages("About", params[:about_filename])
        @sport.save!
        redirect_to about_path
      else
        flash[:notice] = "No filename entered for About page"
        redirect_to :back
      end
    elsif params[:page] == "Contact"    
    end
  end

  def updatecontact
    @page = "Contact"
    render 'sitepages'
  end
  
  def help
  end
  
  def contact
    if current_site?
      puts 'trying to redirect'
      redirect_to sport_contacts_path(current_site)
    else
      render 'contacts/index'
    end
  end
  
  def infofootball
  end

  def infobasketball
  end

  def iphone_basketballinfo
  end

  def webbballinfo
  end

  def pricing
  end

  def mobileinfo
  end
 
  def admin_info
  end

  def websiteinfo
  end

  def ipadexample_path
  end

  def approve
  end

  def eazefootball
  end

  def eazebasketball
  end

  def eazesoccer
  end

  def publisher
  end

  def updatelogo
    begin    
      @sport.logoprocessing = true

      @sport.save!

      queue = @sport.photo_queues.new(modelid: @sport.id, modelname: "sportlogo", filename: params[:filename], filetype: params[:filetype], 
                                      filepath: params[:filepath])
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end

      respond_to do |format|
        format.json { render json: { success: "success", sport: @sport } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message, sport: @sport } }
      end
    end
  end

  private
  
    def correct_sport
      @sport = Sport.find(params[:id])
    end
  
end
