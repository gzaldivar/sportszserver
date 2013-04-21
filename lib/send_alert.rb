module SendAlert

	def send_stat_alerts(athlete, gameschedule, message)
      athlete.followers.each do |user, name|
          athlete.alerts.create!(user: user, athlete: athlete.id, message: message + " " + gameschedule.game_name)
      end		
	end

end
