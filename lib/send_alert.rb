module SendAlert

	def send_stat_alerts(sport, athlete, gameschedule, message)
		athlete.fans.each do |user|
        	alert = athlete.alerts.create!(sport: sport, user: user, athlete: athlete.id, message: message + " " + gameschedule.game_name)
        end		
	end

	def send_placekicker_score_alerts(gamelog)
		if athlete.alerts.where(athlete_id: gamelog.athlete, football_place_kicker: gamelog.football_place_kicker, gamelog: gamelog.id).count == 0
	        gamelog.athlete.fans.each do |user|
	            alert = athlete.alerts.create!(sport: gamelog.athlete.sport, user: user, athlete: gamelog.athlete, message: message + gamelog.game.game_name, 
	                						   football_place_kicker: gamelog.football_place_kicker, stat_football: "Place Kicker")
	        end
	    end
	end
end
