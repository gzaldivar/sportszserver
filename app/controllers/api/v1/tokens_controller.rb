class Api::V1::TokensController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    email = params[:email]
    password = params[:password]
    
    if request.format != :json
        render :status=>406, :json=>{:message=>"The request must be json"}
        return
    end
    
    if email.nil? or password.nil?
      render :status=>400, :json=>{:message=>"The request must contain the user email and password."}
      return
    end
    
    @user=User.find_by(email: email.downcase)
    
    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid email or passoword."}
      return
    end
    
    @user.ensure_authentication_token
    @user.save!
    
    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
    else
      userurl = "missing"
      if !@user.avatar.blank?
        userurl = @user.avatar.url(:tiny)
        userthumb = @user.avatar.url(:thumb)
      end
      sport = Sport.find(@user.default_site)
      render :status=>200, :json=>{email: @user.email, name: @user.name, site: @user.default_site, token: @user.authentication_token, 
                                  avatar: userurl, avatar_thumb: userthumb, bio_alert: @user.bio_alert, blog_alert: @user.blog_alert, 
                                  media_alert: @user.media_alert, stat_alert: @user.stat_alert, score_alert: @user.score_alert, 
                                  sport: sport.id, userid: @user.id, sitename: sport.sitename, banner_url: sport.sport_banner.url(:thumb),
                                  logo: sport.sport_logo.url(:large) }
    end
  end
  
  def destroy
    @user=User.find_by(authentication_token: params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      userurl = "missing"
      if !@user.avatar.blank?
        userurl = @user.avatar.url(:tiny)
        userthumb = @user.avatar.url(:thumb)
      end
      sport = Sport.find(@user.default_site)
      render :status=>200, :json=>{email: @user.email, name: @user.name, site: @user.default_site, token: params[:id], avatar: userurl,
                                  avatar_thumb: userthumb, bio_alert: @user.bio_alert, blog_alert: @user.blog_alert, 
                                  media_alert: @user.media_alert, stat_alert: @user.stat_alert, score_alert: @user.score_alert, 
                                  sport: sport.id, userid: @user.id, sitename: sport.sitename, banner_url: sport.sport_banner.url(:thumb),
                                  logo: sport.sport_logo.url(:large) }
    end
  end
end 