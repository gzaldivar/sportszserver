class UsersController < ApplicationController
	before_filter :authenticate_user!,	only: [:site, :edit, :update]

	def show
	  @user = User.find(params[:id])
	end
	
	def edit
  end
  
  def update
  end

	def site
    if !params[:id].blank?
      site = Site.find(params[:id])
      current_user.default_site = site.id
      current_user.save
      if current_user.sites.count > 0 and admin_site? 
        flash[:notice] = "Your default site is now " + site.sitename + 
                         " which is not a site you administer. You are still adminstrator of the sites you created. 
                         You will be logged into this site when you log in until you change it."
      else
        flash[:notice] = "Your default site is now " + site.sitename
      end
      redirect_to site
    else     
      redirect_to :back, error: "Something went very wrong!"
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

end
