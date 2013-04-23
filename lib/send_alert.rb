module SendAlert

	def send_stat_alerts(sport, athlete, gameschedule, message)
      athlete.followers.each_pair do |user, name|
          athlete.alerts.create!(sport: sport, user: user, athlete: athlete.id, message: message + " " + gameschedule.game_name)
      end		
	end

end
