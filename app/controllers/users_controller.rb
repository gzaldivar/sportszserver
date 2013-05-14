class UsersController < ApplicationController
	before_filter :authenticate_user!,	only: [:site, :edit, :update, :index, :disable, :enable]
  before_filter :get_user, only: [:edit, :show, :update, :disable, :enable]
  before_filter :owner, only: [:edit, :update]

	def show
    respond_to do |format|
      format.html
      format.json
    end
	end

	def edit
      @teams = current_site.teams.all.entries
  end

  def index
    if !params[:site].nil? and !params[:site].blank?
      @users = User.where(default_site: params[:site].to_s).asc(:name, :updated_at).entries
    else
      @users = User.all.entries
    end
  end
  
  def update
    begin
      @user.update_attributes!(params[:user])
      respond_to do |format|
        format.html { redirect_to @user, notice: "User update sucessful!" }
        format.json { render json: { user: @user, request: user_url(@user) } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error updating user data " + e.message }
        format.json { render json: { message: "Error updating user data " + e.message, user: @user, request: user_url(@user) } }
      end
    end
  end

  def disable
    begin
      @user.is_active = false
      @user.save!
      redirect_to :back, notice: "User disabled!"
    rescue Exception => e
      redirect_to :back, notice: "Error disabling user"
    end
  end

  def enable
    begin
      @user.is_active = true
      @user.save!
      redirect_to :back, notice: "User enabled!"
    rescue Exception => e
      redirect_to :back, notice: "Error enabling user"
    end
  end

	def site
    if !params[:id].blank?
      site = Sport.find(params[:id])
      current_user.default_site = site.id
      current_user.save
      if !current_user.mysites.nil? and current_user.mysites.count > 0 and admin_sites? 
        flash[:notice] = "Your default site is now " + site.sitename + 
                         " which is not a site you administer. You are still adminstrator of the sites you created. 
                         You will be logged into this site when you log in until you change it."
      else
        flash[:notice] = "Your default site is now " + site.sitename
      end
      respond_to do |format|
        format.html { redirect_to site }
        format.json { render status: 200, json: { message: "Sucessful", sitename: site.sitename } }
      end
    else     
      redirect_to :back, alert: "Something went very wrong!"
    end
	end
	
	private
	
	  def admin_sites?   
	    site = Sport.where(user_id: current_user.id).each_with_index do |s, cnt|
	      if current_site == site
	        return true
        end
      end
      
      return false	   
	  end

    def get_user
      @user = User.find(params[:id])
    end

    def owner
      if isUserAdmin?(@user) or (!current_user.nil? and (@user.id == current_user.id))
        return true
      end
    end

end
