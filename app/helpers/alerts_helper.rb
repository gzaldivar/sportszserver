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
		return team.alerts.where(teamusers: user.id.to_s).and(:blog.exists => false, :photo.exists => false, :videoclip.exists => false).desc(:updated_at)
	end

	def hasAlerts?(athlete, user)
		return !athlete.alerts.where(users: user.id.to_s).blank?
	end

	def deleteAlert(alert)
		alert.destroy
	end

end
