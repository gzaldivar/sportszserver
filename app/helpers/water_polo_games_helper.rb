module WaterPoloGamesHelper

	def waterpolo_playergoals(game, player)
		stat = game.water_polo_game.waterpolo_stats.find_by(athlete_id: player.id)

		if stat
			return stat.waterpolo_scorings.count
		else
			return 0
		end
	end

	def waterpolo_playerassists(game, player)
		assists = 0
		stat = game.water_polo_game.waterpolo_stats.find_by(athlete_id: player.id)

		if stat
			stat.waterpolo_scorings.each do |w|
				if w.assists = player.id.to_s
					assists += 1
				end
			end
		else
			assists = 0
		end

		return assists
	end

	def waterpolo_playershots(game, player)
		shots = 0
		stat = game.water_polo_game.waterpolo_stats.find_by(athlete_id: player.id)

		if stat
			stat.waterpolo_playerstats.each do |w|
				shots += w.shots
			end
		else
			shots = 0
		end

		return shots
	end

	def waterpolo_playersteals(game, player)
		steals = 0
		stat = game.water_polo_game.waterpolo_stats.find_by(athlete_id: player.id)

		if stat
			stat.waterpolo_playerstats.each do |w|
				steals += w.steals
			end
		else
			steals = 0
		end

		return steals
	end

end
