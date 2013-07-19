class UsersController < ApplicationController
	before_filter :authenticate_user!,	only: [:site, :edit, :update, :index, :disable, :enable, :delete_avatar]
  before_filter :get_user, only: [:edit, :show, :update, :disable, :enable, :delete_avatar, :getuser]
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
    if !params[:site].blank? and !params[:email].blank? and !params[:name].blank?
      @users = User.full_text_search(params[:site].to_s + " " + params[:email].to_s + " " + params[:name].to_s, match: :all).asc(:name, :updated_at).entries
    elsif !params[:site].blank? and !params[:name].blank? 
      @users = User.full_text_search(params[:site] + " " + params[:name].to_s, match: :all).asc(:name, :updated_at).entries
    elsif !params[:site].blank? and !params[:email].blank?
      @users = User.full_text_search(params[:site] + " " + params[:email].to_s, match: :all).asc(:name, :updated_at).entries
     elsif !params[:site].nil? and !params[:site].blank?
      @users = User.where(default_site: params[:site].to_s).asc(:name, :updated_at).entries
    else
      @users = User.all.entries
    end

    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def update
    begin
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
      @user.update_attributes!(params[:user])

      @user.reset_authentication_token
      @user.save!
      respond_to do |format|
        format.html { redirect_to @user, notice: "User update sucessful!" }
        format.json { render json: { user: @user, authentication_token: @user.authentication_token, request: user_url(@user) } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error updating user data " + e.message }
        format.json { render json: { message: "Error updating user data " + e.message, user: @user, request: user_url(@user) } }
      end
    end
  end

  def update_user_info
    begin
      if params[:user][:name]
        @user.name = params[:user][:name]
      end
      if params[:user][:email]
        @user.email = params[:user][:email]
      end
      if params[:user][:content_type]
        @user.original_filename = params[:user][:original_filename]
        @user.image_data = params[:user][:image_data]
        @user.content_type = params[:user][:content_type]
      end
      if params[:user][:is_active] and params[:user][:is_active] == "1"
        @user.is_active = true
      elsif params[:user][:is_active] and params[:user][:is_active] == "0"
        @user.is_active = false
      end

      @user.save!

      respond_to do |format|
        format.html { redirect_to user_path(@user), notice: "Update sucessful!" }
        format.json { render status: 200, json: { request: user_path(@user) } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to user_path(@user), alert: e.message }
        format.json { render status:400, json: { error: e.message, request: user_path(@user) } }
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
    begin
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
          format.json { render status: 200, json: { site: site, sitename: site.sitename } }
        end
      else    
        redirect_to :back, alert: "Something went very wrong!"
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to @user, alert: e.message }
        format.json { render status: 404, json: { error: e.message, request: @user } }
      end
    end
	end

  def delete_avatar
    begin
      @user.avatar.clear
      @user.save!
      respond_to do |format|
        format.html { redirect_to @user, notice: "Image Removed" }
        format.json { render json: { user: @user, request: @user } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to @user, notice: "Error removing image" }
        format.json { render status: 404, json: { error: e.message, request: @user } }
      end
    end
  end

  def getuser
    respond_to do |format|
      format.json
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
