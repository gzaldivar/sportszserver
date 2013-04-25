class UsersController < ApplicationController
	before_filter :authenticate_user!,	only: [:site, :edit, :update, :index, :disable, :enable]
  before_filter :get_user, only: [:edit, :show, :update, :disable, :enable]
  before_filter :owner, only: [:edit, :update]

	def show
	end

	def edit
    if current_site.sports.all.count == 1
      @teams = current_site.sports.first.teams.all.entries
    else
    end
  end

  def index
    if !params[:site].nil? and !params[:site].blank?
      @users = User.where(default_site: params[:site].to_s).asc(:name, :updated_at).entries
    else
      @users = User.all.entries
    end
  end
  
  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: "User update sucessful!"
    else
      redirect_to :back, alert: "Error updating user data"
    end
  end

  def disable
    @user.disable = true
  end

  def enable
    @user.disable = false
  end

	def site
    if !params[:id].blank?
      site = Site.find(params[:id])
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
	    site = Site.where(user_id: current_user.id).each_with_index do |s, cnt|
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
