module UsersHelper

	def site_owner?
	  	if current_site? and !current_user.nil? and current_user.admin?
		  	if current_user.id.to_s != current_site.adminid
		  		not_authorized
#		  		redirect_to :back, alert: "You are not the site owner"
		  	else
		  		return true
		  	end
	  	else
	  		not_authorized
#	    	redirect_to :back, notice: "Action not allowed"
    	end
	end

	def isAdmin?
		if !current_user.nil? and current_site?
			return current_site.adminid == current_user.id.to_s
		else
			return nil
		end
	end

	def isUserAdmin?(user)
		user.admin
	end

	def user_enabled?
		current_user.disable
	end
	
end
