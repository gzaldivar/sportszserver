class SitesController < ApplicationController
  respond_to :html, :json, :xml
  before_filter :authenticate_user!,     only: [:new, :create, :edit, :update, :destroy, :uploadpage, :updateabout]
  before_filter :site_owner?,           only: [:edit, :update, :destroy, :updateabout, :uploadpage, :male, :female]
  before_filter :correct_site,          only: [:show, :update, :edit, :destroy, :updateabout, :uploadpage]
   
  def home
    clear_site
    if user_signed_in?
      @admin_sites = []
      current_user.sites.each_with_index do |s, cnt|
        @admin_sites[cnt] = s
      end
    end

    respond_to do |format|
      format.html
      format.json { respond_with( { home2x: view_context.asset_path('IOSHome@2x.png'), home: view_context.asset_path('IOSHome.png') }) }
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
      redirect_to site_contacts_path(current_site)
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
  
  def new
  	@site = Site.new
    
    respond_to do |format|
      format.html { render 'new'}
      format.xml
      format.json 
      format.js
    end
  end
  
  def male
    current_site.sportsexdefault = "Male"
    current_site.save
    sleep(1)
    redirect_to current_site
  end
  
  def female
    current_site.sportsexdefault = "Female"
    current_site.save
    sleep(1)
    redirect_to current_site
  end
  
  def show
    site_visit(@site)
    @sports = []
    @site.sports.where(sex: @site.sportsexdefault).each_with_index do |s, cnt|
       @sports[cnt] = s
    end

    if @sports.many? # || !current_site.sportsexdefault.nil?
      @fall = []
      @winter = []
      @spring = [] 
      @summer = []
      fcnt = 0 
      wcnt = 0 
      scnt = 0 
      smcnt = 0
      @sports.each do |s|
        case s.season
        when "Fall"
          @fall[fcnt] = s
          fcnt+=1
        when "Winter"
          @winter[wcnt] = s
          wcnt+=1
        when "Spring"
          @spring[scnt] = s
          scnt+=1
        when "Summer"
          @summer[smcnt] = s
          smcnt+=1
        end
      end
      
      @newsfeed = get_site_news(10)
          
      respond_to do |format|
        format.html { render 'show'}
        format.xml
        format.json { render status: 200, json: { id: @site.id, sitename: @site.sitename, mascot: @site.mascot, 
                      logo_thumburl: @site.logo_thumburl } }
        format.js
      end
    elsif @sports.count == 1
      redirect_to sport_path(id: @sports[0].id)
    else
      redirect_to new_sport_path
    end    
  end
  
  def create
    @site = current_user.sites.build(params[:site])
    @site.city = @site.zip.to_region(city: true)
    @site.state = @site.zip.to_region(state: true)
    @site.contactemail = current_user.email
    @site.adminid = current_user.id

    if @site.save
      current_user.mysites = { @site.id => @site.sitename }
      current_user.admin = true
      current_user.save

      flash[:success] = "New Site created!"
      
      respond_to do |format|
        format.html { redirect_to @site}
        format.xml
        format.json 
        format.js
      end
    else
    	
      redirect_to :back, alert: "Error creating site"
    end
  end
  
  def edit
    @sports = @site.sports
  end
  
  def index
    @sites = []
    if !params[:zip].blank? and !params[:city].blank? and !params[:state].blank? and !params[:sitename].blank?
      site = Site.full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s + " " + params[:sitename].to_s, match: :all)      
    elsif !params[:zip].blank? and !params[:city].blank? and !params[:state].blank?
      site = Site.full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s, match: :all)
    elsif !params[:zip].blank?
      site = Site.full_text_search(params[:zip].to_s)
    elsif !params[:city].blank?
      site = Site.full_text_search(params[:city].to_s)
    elsif !params[:state].blank?
      site = Site.full_text_search(params[:state].to_s)
    elsif !params[:sitename].blank?
      puts "got here " + params[:sitename].to_s
      site = Site.full_text_search(params[:sitename].to_s)
    elsif params[:all]
      site = Site.all
     end

    if site 
      site.each_with_index do |s, cnt|
         @sites[cnt] = s
      end
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def update
    zip = params[:site][:zip]
    if zip.match(/\A(\d{5}\z)|(\d{5}-\d{4}\z)/)
      @site.city = zip.to_region(city: true)
      @site.state = zip.to_region(state: true)
      if @site.update_attributes(params[:site])
       flash[:success] = "Site updated"
        
        respond_to do |format|
          format.html { redirect_to @site}
          format.xml
          format.json 
          format.js
        end
      else
        
        redirect_to :back, alert: "Error updating site information"
      end
    else
      redirect_to :back, alert: "Invalid zip code"
    end
  end

  def destroy
    @site.delete
    redirect_to root_url
  end
  
  def allnews
    @newsfeed = get_site_news(100)
  end
    
  private

    def correct_site
      if params[:id]
        @site = Site.find(params[:id])
      elsif current_site?
        @site = current_site
      end
      redirect_to root_url if @site.nil?
    end
    
    def get_site_news(number)
      sports = current_site.sports
      newsfeed = []
      sports.each do |s|
        s.newsfeeds.where(allsports: true).limit(number).each_with_index do |n, cnt|
          newsfeed[cnt] = n
        end
      end
      return newsfeed
    end
        
end
