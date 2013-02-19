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

  private
  
    def after_sign_out_path_for(resource)
      if current_site?
        site_path(current_site)
      else
        root_path
      end
    end

    def after_sign_in_path_for(resource)
      if current_user.default_site
        site_path(current_user.default_site)
      else
        root_path
      end
    end
  
end

