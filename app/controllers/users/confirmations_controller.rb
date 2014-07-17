class Users::ConfirmationsController < Devise::ConfirmationsController
  protected
    def after_confirmation_path_for(resource_name, resource)
		UserMailer.welcome_mail(@user).deliver
		
     	if resource.mobile == "Web"
			if resource.default_site.nil?
				root_path
			else
				sport_path(resource.default_site)
			end
		else
			clientapp_path(mobile: resource.mobile, email: resource.email, admin: resource.admin)
#			render js: "window.location = '#{resource.mobile}://#{resource.email}'"
		end
   end
end