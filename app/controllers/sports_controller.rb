class SportsController < ApplicationController
  before_filter :authenticate_user!,    only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:edit, :update, :destroy]
  before_filter :correct_sport,         only: [:show, :edit, :update, :destroy, :sport_user_alerts, :updatelogo]
   
  def new
    @sport = Sport.new
    @sport.teams.build
  end
  
  def create
    begin
      @sport = current_user.sports.build(params[:sport])
      @sport.city = @sport.zip.to_region(city: true)
      @sport.state = @sport.zip.to_region(state: true)
      @sport.contactemail = current_user.email
      @sport.adminid = current_user.id

      if !@sport.sportname.blank?
        @sport.name = @sport.sportname
        @sport.has_stats = true
      end
      
      if @sport.save!
        current_user.admin = true
        current_user.default_site = @sport.id
        current_user.save

        respond_to do |format|
          format.html { redirect_to @sport, notice: "New Sport Site created!" }
          format.json { render json: { sport: @sport, request: @sport } }
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
    @newsfeed = @sport.newsfeeds.limit(10).desc(:updated_at)
    @athletes = @sport.athletes
    @followed = []
    if signed_in?
      cnt = 0
      @athletes.each do |a|
        if a.fans.include?(current_user.id)
          @followed[cnt] = a
          cnt+=1
        end
      end
    end
    
    respond_to do |format|
      format.html
      format.json 
     end
  end
  
  def index
    @sports = []
    if !params[:zip].blank? and !params[:city].blank? and !params[:state].blank? and !params[:sitename].blank?
      site = Sport.full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s + " " + params[:sitename].to_s, match: :all)      
    elsif !params[:zip].blank? and !params[:city].blank? and !params[:state].blank?
      site = Sport.full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s, match: :all)
    elsif !params[:zip].blank?
      site = Sport.full_text_search(params[:zip].to_s)
    elsif !params[:city].blank?
      site = Sport.full_text_search(params[:city].to_s)
    elsif !params[:state].blank?
      site = Sport.full_text_search(params[:state].to_s)
    elsif !params[:sitename].blank?
      site = Sport.full_text_search(params[:sitename].to_s)
    elsif params[:all]
      site = Sport.all
     end

    if site 
      site.each_with_index do |s, cnt|
         @sports[cnt] = s
      end
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
    @page = "About"
    render 'sitepages'
  end

  def uploadpage
    if params[:site][:page] == "About"
      if !params[:site][:about_filename].blank?
        @site.sitepages("About", params[:site][:about_filename])
        @site.save
        redirect_to about_path
      else
        flash[:notice] = "No filename entered for About page"
        redirect_to :back
      end
    elsif params[:site][:page] == "Contact"    
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
      redirect_to sport_contacts_path(current_site)
    else
      render 'contacts/index'
    end
  end
  
  def info
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
