module SendAlert

	def send_stat_alerts(sport, athlete, gameschedule, message)
		athlete.fans.each do |user|
        	alert = athlete.alerts.create!(sport: sport, user: user, athlete: athlete.id, message: message + " " + gameschedule.game_name)
        end		
	end

end
