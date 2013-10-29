class ApplicationController < ActionController::Base
  protect_from_forgery
  
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

#  def not_authorized
#    raise ActionController::RoutingError.new('You are not Authorized for this')
#  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, with: lambda { |exception| render_error 404, exception }
  end

  private
  
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
    
      if resource.default_site and !sport.nil?                      # if the user has a default site

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
        elsif resource.admin
          if !current_site.nil?
            flash[:error] = "Admin user cannot be used to login to other Eazesportz sites. Login to " + current_site.sitename + " failed!"
           end
        end

        sport_path(resource.default_site)
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

end

