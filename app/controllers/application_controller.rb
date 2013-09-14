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
      if current_user.default_site and !Sport.find(current_user.default_site).nil?
        sport_path(current_user.default_site)
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

