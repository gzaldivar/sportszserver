module AlertsHelper

	def send_alerts(athlete)
		athlete.followers.each do |user, name|
      		alert = @athlete.alerts.new(user: user, message: "Athlete info updated")
      		alert.save
      	end
	end

	def athlete_alerts(athlete)
		return athlete.alerts.all.entries
	end

	def getTeamAlerts(team, user)
		return team.alerts.where(user_id: user.id, :gamelog.ne => "", :gamelog.exists => true).desc(:updated_at)
	end

	def hasAlerts?(athlete, user)
		return !athlete.alerts.where(user: user.id).blank?
	end

end
