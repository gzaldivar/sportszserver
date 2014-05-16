module LacrosseStatistics

	mattr_accessor :totals

	def lacrossehomescore(game)
		score = 0

		game.lacrosses.each do |l|
			score += l.goal 
		end

		return score
	end

	def lacrosse_clearing_percentage(game)
		game.lacrosse_clears/(lacrosse_clears + game.lacrosse_badclears)
	end

	def lacrosse_points_per_game(sport, player)
		total_points = 0

		games = sport.teams.find(anobject.team_id).gameschedules

		games.each do |g|
			stats = g.lacrosses.find_by(athlete_id: player.id)

			if !stats.nil?
				total_points += stats.goal + stats.assist
			end
		end

		return total_points / games.count
	end

	# team statistics for player

	def lacrosse_scoring_average(sport, player)
		goals = 0
		games = sport.teams.find(player.team_id).gameschedules

		games.each do |g|
			stat = g.lacrosses.find_by(athlete_id: player.id)
			goals += stat.goal
		end

		if games > 0
			return goals / games.count
		else
			return 0.0
		end
	end

	def lacrosse_scoring_defense(sport, player)
		goals_allowed = 0
		games = sport.teams.find(player.team_id).gameschedules

		games.each do |g|
			stat = g.lacrosses.find_by(athlete_id: player.id)
			goals_allowed += stat.goal_allowed
		end
		
		if games > 0
			return goals_allowed / games.count
		else
			return 0.0
		end
	end

	def lacrosse_scoring_margin(team)			# compute scoring margin for team for all games
		goals_allowed = 0
		goals = 0
		games = team.gameschedules

		games.each do |g|
			goals_allowed += g.goal_allowed
			goals += g.goal
		end
		
		if games > 0
			return (goals + goals_allowed )/games.count
		else
			return 0.0
		end		
	end

	def lacrosse_save_percentage(sport, anobject)
		totalsaves = 0
		goals = 0

		if anobject.kind_of?(Athlete)
			sport.teams.find(anobject.team_id).gameschedules.each do |g|
				stat = g.lacrosses.find_by(athlete_id: anobject.id)

				if !stat.nil?
					goals += stat.goal
					totalsaves += stat.saves
				end
			end
		elsif anobject.kind_of?(Gameschedule)
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosses.find_by(gameschedule_id: anobject.id)

				if !stat.nil?
					goals += stat.goal
					totalsaves += stat.saves
				end
			end
		end

		if totalsaves > 0 and goals > 0
			return totalsaves/(totalsaves + goals)
		else
			return 0.0
		end
	end

	def lacrosse_goals_against_average(sport, anobject)
		goals_allowed = 0
		total_minutes_played = 0

		if anobject.kind_of?(Athlete)
			sport.teams.find(anobject.team_id).gameschedules.each do |g|
				stat = g.lacrosses.find_by(athlete_id: anobject.id)

				if !stat.nil?
					goals_allowed += stat.goal_allowed
					total_minutes_played += stat.minutesplayed
				end
			end
		else
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosses.find_by(gameschedule: anobject.id)

				if !stat.nil?
					goals_allowed += stat.goal_allowed
					total_minutes_played += stat.minutesplayed
				end
			end
		end

		if total_minutes_played > 0
			(goals_allowed * 60)/total_minutes_played
		else
			return 0.0
		end
	end

	def lacrosse_shooting_accuracy(sport, anobject)
		goals = 0
		shots = 0

		if anobject.kind_of?(Athlete)
			sport.teams.find(anobject.team_id).gameschedules.each do |g|	# player stats for all games
				stat = g.lacrosses.find_by(athlete_id: anobject.id)

				if !stat.nil?
					goals += stat.goal
					shots += stat.shots
				end
			end
		else								# computing stats for game from players
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosses.find_by(gameschedule_id: anobject.id)

				if !stat.nil?
					goals += l.goal
					shots += l.shot
				end
			end
		end


		if shots > 0
			return goals/shots
		else
			return 0.0
		end
	end

	class Lacrossestats

		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.lacrosses

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules.asc(:gamedate)

				@stats = []

				games.each do |g|
					found = false
					thestats.each do |s|
						if s.gameschedule_id == g.id
							@stats << s
							found = true
						end
					end
					if !found
						@stats << Lacrosse.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id).asc(:number)

				@stats = []

				players.each do |p|
					found = false
					thestats.each do |s|
						if p.id == s.athlete_id
							@stats << s
							found = true
						end
					end
					if !found
						@stats << Lacrosse.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end

			@stats.sort_by! { |obj| obj.goal }.reverse!
		end

		def stattotals
			if @playergame.kind_of?(Athlete)
				totals = Lacrosse.new(athlete_id: @playergame.id)
			else
				totals = Lacrosse.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.goal += s.goal
				totals.shot += s.shot
				totals.free_position_sog += s.free_position_sog
				totals.assist += s.assist
				totals.draw_control += s.draw_control
				totals.ground_ball += s.ground_ball
				totals.interception += s.interception
				totals.turnover += s.turnover
				totals.caused_turnover += s.caused_turnover
				totals.foul += s.foul
				totals.clear += s.clear
				totals.save += s.save
				totals.minutesplayed += s.minutesplayed
			end

			return totals
		end
	end

end
