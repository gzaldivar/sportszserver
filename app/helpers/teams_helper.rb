module TeamsHelper

	def find_team(teamid)
		if !teamid.nil?
			if team = current_site.teams.find(teamid)
				return team
			end 
		end
	end

	def team_manager?(item, team)
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

end
