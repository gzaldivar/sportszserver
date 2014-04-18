module UsersHelper

	def site_owner?(sport)
		if !sport.approved?
			return false
	  	elsif !current_user.nil? and current_user.admin?
		  	if current_user.id.to_s != sport.adminid and !current_user.godmode
		  		return false
		  	else
		  		return true
		  	end
	  	else
#	  		not_authorized
			return false
    	end
	end

	def SiteOwner?(teamid)
		if current_site? and !current_site.approved?
			raise ActionController::RoutingError.new('you are not Authorized for this')
	  	elsif current_site? and !current_user.nil? and current_user.admin?
		  	if current_user.id.to_s != current_site.adminid and !current_user.godmode
		  		raise ActionController::RoutingError.new('you are not Authorized for this')
		  	else
		  		return true
		  	end
		elsif teamid and current_site? and user_signed_in?
			if !current_user.teamid == teamid
	  			raise ActionController::RoutingError.new('you are not Authorized for this')
	  		else
	  			return true
	  		end
	  	elsif teamid and current_user.admin 
			sport = Sport.where('teams._id' => Moped::BSON::ObjectId(teamid)).first
			team = sport.teams.find(teamid)

			if current_user.adminsite == team.sport.id.to_s
				return true
			else
				return false
			end
	  	else
	  		raise ActionController::RoutingError.new('you are not Authorized for this')
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
