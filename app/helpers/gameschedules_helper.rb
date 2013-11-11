module GameschedulesHelper

	def basketball_home_score(game)
		players = @sport.athletes.where(team_id: game.team_id)
		score = 0

		players.each do |p|
			stats = p.basketball_stats.find_by(gameschedule_id: game.id.to_s)
			if !stats.nil?
				score += (stats.twomade * 2) + (stats.threemade * 3) + stats.ftmade
			end
		end

		return score
	end

	def basketball_home_fouls(game)
		players = @sport.athletes.where(team_id: game.team_id)
		fouls = 0

		players.each do |p|
			stats = p.basketball_stats.find_by(gameschedule_id: game.id.to_s)
			if !stats.nil?
				fouls += stats.fouls
			end
		end

		return fouls
	end

	def soccer_home_score(game)
		players = @sport.athletes.where(team_id: game.team_id)
		score = 0

		players.each do |p|
			stats = p.soccers.find_by(gameschedule_id: game.id.to_s)
			if !stats.nil?
				score += stats.goals
			end
		end

		return score
	end

end
