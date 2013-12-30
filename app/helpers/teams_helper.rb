module TeamsHelper

	def find_team(teamid)
		if !teamid.nil?
			if team = current_site.teams.find(teamid)
				return team
			end 
		end
	end

	def team_manager?(item, team)
		if user_signed_in?
			if item.nil? and !team.nil? and (team.id.to_s == current_user.teamid)
				return true
			elsif item.respond_to?('team') and (current_user.teamid == item.team)
				return true
			elsif item.respond_to?('team_id') and (current_user.teamid == item.team_id.to_s)
				return true
			elsif item.respond_to?('teamid') and (current_user.teamid == item.teamid)
				return true
			else
				site_owner?
			end
		else
		end
	end

	def isTeamManager?(item)
		if !current_user.nil? and current_site?
			if item.respond_to?('team') and !item.team.nil?
				return current_user.teamid == item.team
			elsif item.respond_to?('teamid') and !item.teamid.nil?
				return current_user.teamid == item.teamid
			elsif item.respond_to?('team_id') and !item.team_id.nil?
				return current_user.teamid == item.team_id.to_s
			else
				return nil
			end
		else
			return nil
		end
	end

	def get_team_logo(sport, team)
		if team.team_logo?
			return team.team_logo(:thumb)
		elsif sport.sport_logo?
			sport.sport_logo(:thumb)
		else
			return "photo_not_available.png"
		end
	end

	def set_current_team(team)
		if current_site? and current_team != team.id
			session[:current_team] = team.id
			self.current_team = team
		end
	end

	def current_team=(team)
		@current_team = team
	end

	def current_team
		if current_site?
			if !session[:current_team].nil?
				return  @current_team ||= current_site.teams.find(session[:current_team])
			else
			 	return nil
			end
		end
	end
  
	def current_team?
		!current_team.nil?
	end

end
