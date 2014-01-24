class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user_from_token!
  # This is Devise's authentication
  before_filter :authenticate_user!

  include ApplicationHelper
  include PhotosHelper
  include SitesHelper
  include SportsHelper
  include NewsfeedsHelper
  include AthletesHelper
  include CoachesHelper
  include UsersHelper
  include FootballStatsHelper
  include TeamsHelper
  include AlertsHelper
  include SponsorsHelper
  include SoccersHelper
  include GameschedulesHelper

  unless Rails.application.config.consider_all_requests_local
#    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
#    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, with: lambda { |exception| render_error 404, exception }
    rescue_from Exception do |exception|
      logger.error(exception)
      render "/errors/error_500", :status => 500
    end
#    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError do |exception|
      logger.error(exception)
  #    raise ActionController::RoutingError.new('You are not Authorized for this')
      @message = exception.message
      render "/errors/error_404", :status => 404
    end
#    rescue_from ActionController::UnknownController, :with => :render_not_found
#    rescue_from ActionController::UpgradeNeeded, :with => :upgrade_needed
  end

  private

    def checklogin(controller)
      if current_site? and controller.controller_name == "sports" and (controller.action_name == "home" or controller.action_name == "pricing")
        logger.debug controller.action_name
        logger.debug controller.controller_name
        redirect_to sport_path(current_site)
      end
    end

    def upgrade_needed(exception)
      logger.error(exception)
#      raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality')
      render :template => "/errors/error_upgrade.html.erb", :status => 404
    end

    def after_sign_out_path_for(resource)
      if current_site?
        sport_path(current_site)
      else
        root_path
       end
    end

    def after_sign_in_path_for(resource)
      if resource.default_site.nil?
        sport = nil
      else
        sport = Sport.find(resource.default_site)
      end
    
      if !sport.nil?                      # if the user has a default site

        # if the current site sport is not the default sport they are logging into a new sport

        if !resource.admin and !current_site.nil? and 
           (current_site.name != sport.name or (current_site.name == sport.name and current_site.id != sport.id))

          # See if the user has logged into this sport type before. If not, add this sport to the users list. If the user does have this sport
          # in their list, then replace this site for that sport in the user list

#          if !resource.mysites.detect {|f| f[current_site.name] == sport.name }
          if resource.mysites.nil?
            resource.mysites = Hash.new
          end

          resource.mysites[current_site.name] = current_site.id

          resource.default_site = current_site.id
          resource.save!
        elsif resource.admin and !current_site.nil? and current_site.adminid.to_s != resource.id.to_s
          flash[:error] = "Admin user cannot be used to login to other Eazesportz sites. Login to " + current_site.sitename + " failed!"
        end
        sport_path(id: resource.default_site)
      else
        root_path
      end
    end

    def render_error(status, exception)
      puts exception.message
      respond_to do |format|
        format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
        format.json { render status: status, json: { error: exception.message } }
        format.all { render nothing: true, status: status }
      end
    end

    # For this example, we are simply using token authentication
    # via parameters. However, anyone could use Rails's token
    # authentication features to get the token from a header.
    def authenticate_user_from_token!
      puts params[:auth_token]
      user_token = params[:auth_token].presence
      user       = user_token && User.find_by(authentication_token: user_token)
   
      if user
        # Notice we are passing store false, so the user is not
        # actually stored in the session and a token is needed
        # for every request. If you want the token to work as a
        # sign in token, you can simply remove store: false.
        sign_in user, store: false
      end
    end
end

