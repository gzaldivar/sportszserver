module TeamsHelper

	def find_team(teamid)
		if !teamid.nil?
			current_site.sports.each do |s|
				if team = s.teams.find(teamid)
					return team
				end 
			end
		end
	end

	def team_manager?(teamid)
		current_user.teamid == teamid
	end
end
