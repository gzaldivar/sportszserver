class Users::ConfirmationsController < Devise::ConfirmationsController
  protected
    def after_confirmation_path_for(resource_name, resource)
      if resource.default_site.nil?
        root_path
      else
        sport_path(resource.default_site)
      end
    end
end