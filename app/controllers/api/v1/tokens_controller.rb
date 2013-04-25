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
      end
      site = Site.find(@user.default_site)
      sports = onesport?(site.id)
      if !sports.kind_of?(Array)
        render :status=>200, :json=>{email: @user.email, name: @user.name, site: @user.default_site, token: @user.authentication_token, 
                                  avatar: userurl, sport: sports.id, userid: @user.id, sitename: site.sitename, banner_url: site.banner.url(:thumb),
                                  logo: site.logo.url(:large) }
      else
        thesport = getsport(sports, params[:sport])
        render :status=>200, :json=>{email: @user.email, name: @user.name, site: @user.default_site, token: @user.authentication_token, 
                                  avatar: userurl, userid: @user.id, sport:  thesport, sitename: site.sitename, banner_url: site.banner.url(:thumb),
                                  logo: site.logo.url(:large) }
      end
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
      end
      sports = onesport?(@user.default_site)
      if !sports.kind_of?(Array)
        render :status=>200, :json=>{email: @user.email, name: @user.name, site: @user.default_site, token: params[:id], 
                                  avatar: userurl, userid: @user.id, sport: sports.id,  sitename: site.sitename, banner_url: site.banner.url(:thumb),
                                  logo: site.logo.url(:large)}
      else
        thesport = getsport(sports, params[:sport])
        render :status=>200, :json=>{email: @user.email, name: @user.name, site: @user.default_site, token: @user.authentication_token, 
                                  avatar: userurl, userid: @user.id, sport:  thesport, sitename: site.sitename, banner_url: site.banner.url(:thumb),
                                  logo: site.logo.url(:large) }
      end
    end
  end

  private

    def onesport?(siteid)
      site = Site.find(siteid)
      if site.sports.all.count == 1
        return site.sports.first
      else
        return site.sports.all.entries
      end
    end

    def getsport(objs, sport)
      spobj = nil
      objs.each do |o|
        if o.name == sport
          spobj = o
        end
      end
      return spobj
    end
end 