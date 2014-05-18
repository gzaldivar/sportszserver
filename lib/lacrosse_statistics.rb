module LacrosseStatistics

#	mattr_accessor :totals

	def lacrossehomescore(game)
		score = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				score.each_with_index do |s, i|
					s = l.lacross_scorings.where(scoretype: "Goal", period: i).count if l.lacross_scorings
				end
			end
		end

		return score
	end

	def lacrosshomeassists(game)
		score = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				score.each_with_index do |s, i|
					s = l.lacross_scorings.where(scoretype: "Assist", period: i).count if l.lacross_scorings
				end
			end
		end

		return score
	end

	def lacrosshompenalties(game)
		penalty = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				score.each_with_index do |s, i|
					s = l.lacross_penalties.where(period: i).count if l.lacross_penalties
				end
			end
		end

		return penalty
	end

	def lacrossevisitorscore(game)
		score = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.visiting_team and game.lacross_game.visiting_team.visitor_rosters
			game.lacross_game.visiting_team.visitor_rosters.each do |v|
				if v.lacross and v.lacross.lacross_scorings.any?
					score.each_with_index do |s, i|
						s += v.lacross.lacross_scorings.where(scoretype: "Goal", period: i).count if v.lacross.lacross_scorings.any?
					end
				end
			end
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
			stats = g.lacrosstats.find_by(athlete_id: player.id)

			if !stats.nil? and stats.lacross_scorings.any?
				total_points += stats.lacross_scorings.count
			end
		end

		return total_points / games.count
	end

	# team statistics for player

	def lacrosse_scoring_average(sport, player)
		goals = 0
		games = sport.teams.find(player.team_id).gameschedules

		games.each do |g|
			stat = g.lacrosstats.find_by(athlete_id: player.id)
			goals += stat.lacross_scorings.count if stat.lacross_scorings.any?
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
			stat = g.lacrosstats.find_by(athlete_id: player.id)
			goals_allowed += stat.lacross_goalstat.goals_allowed.each { |a| sum+=a } if stat.lacross_goalstats.any?
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
			g.lacrosstats.each do |l|
				l.lacross_goalstats.each do |stat|
					goals_allowed += stat.goals_allowed
					goals += stat.goal
				end
			end
		end
		
		if games > 0
			return (goals - goals_allowed )/games.count
		else
			return 0.0
		end		
	end

	def lacrosse_save_percentage(sport, anobject)
		totalsaves = 0
		goals_allowed = 0

		if anobject.kind_of?(Athlete)
			sport.teams.find(anobject.team_id).gameschedules.each do |g|
				stat = g.lacrosstats.find_by(athlete_id: anobject.id)

				if !stat.nil?  and !stat.lacross_goalstats.nil?
					stat.lacross_goalstats.each do |l|
#						goals_allowed += l.goals_allowed.each { |a| sum+=a }
						goals_allowed += l.goals_allowed
						totalsaves += l.saves
					end
				end
			end
		elsif anobject.kind_of?(Gameschedule)
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosstats.find_by(gameschedule_id: anobject.id)

				if !stat.nil? and !stat.lacross_goalstats.nil?
					stat.lacross_goalstats.each do |l|
						goals_allowed += l.goals_allowed
						totalsaves += l.saves
					end
				end
			end
		end

		if totalsaves > 0 and goals > 0
			return totalsaves/(totalsaves + goals_allowed)
		else
			return 0.0
		end
	end

	def lacrosse_goals_against_average(sport, anobject)
		goals_allowed = 0
		total_minutes_played = 0

		if anobject.kind_of?(Athlete)
			sport.teams.find(anobject.team_id).gameschedules.each do |g|
				stat = g.lacrosstats.find_by(athlete_id: anobject.id)

				if !stat.nil? and !stat.lacross_goalstats.nil?
					stat.lacross_goalstats.each do |l|
						goals_allowed += l.goals_allowed
						total_minutes_played += l.minutesplayed
					end
				end
			end
		else
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosstats.find_by(gameschedule: anobject.id)

				if !stat.nil? and !stat.lacross_goalstats.nil?
					stat.lacross_goalstats.each do |l|
						goals_allowed += l.goals_allowed
						total_minutes_played += l.minutesplayed
					end
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
				stat = g.lacrosstats.find_by(athlete_id: anobject.id)

				if !stat.nil?
					statgoals = stat.lacross_scorings.where(scoretype: "Goal")
					goals += statgoals.count
					shots += stat.lacross_player_stats.shots
				end
			end
		else								# computing stats for game from players
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosstats.find_by(gameschedule_id: anobject.id)

				if !stat.nil?
					statgoals = stat.lacross_scorings.where(scoretype: "Goal")
					goals += statgoals.goal
					shots += l.lacross_player_stats.shot
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
			@totalscoringstats = 0

			if anobject.kind_of?(Athlete)
				thestats = anobject.lacrosstats
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
						@stats << Lacrosstat.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				if anobject.lacross_game
					thestats = anobject.lacross_game.lacrosstats
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
							@stats << Lacrosstat.new(gameschedule_id: anobject.id, athlete_id: p.id)
						end
					end
				else
					@stats = []
				end
			end
		end

		def playerstats
			gamestats = Array.new

			@stats.each do |s|
				thestats = { }

				if s.lacross_player_stats.any?
					s.lacross_player_stats.asc(:period).each do |p|
						thestats[:shot] = p.shot
						thestats[:face_off_won] = p.face_off_won
						thestats[:face_off_lost] = p.face_off_lost
						thestats[:ground_ball] = p.ground_ball
						thestats[:interception] = p.interception
						thestats[:turnover] = p.turnover
						thestats[:caused_turnover] = p.caused_turnover
					end
				else
					thestats = { :shot => 0, :face_off_won => 0, :face_off_lost => 0, :ground_ball => 0, :interception => 0, :turnover => 0, 
								:caused_turnover => 0 }
				end

				if s.lacross_scorings.any?
					s.lacross_scorings.each do |stat|
						thestats[:goal] += 1 if stat.scoretype == "Goal"
						thestats[:assist] += 1 if stat.scoretype == "Assist"
					end
				else
					thestats[:goal] = 0
					thestats[:assist] = 0
				end

				thestats[:athlete_id] = s.athlete_id.to_s
				thestats[:gameschedule_id] = s.gameschedule_id.to_s

				gamestats << thestats
			end


			return gamestats
		end

		def playertotals
			totals = { :shot => 0, :face_off_won => 0, :face_off_lost => 0, :ground_ball => 0, :interception => 0, :turnover => 0, 
						:caused_turnover => 0, :goal => 0, :assist => 0 }

			@stats.each do |s|
				s.lacross_player_stats.each do |stat|
					totals[:shot] += stat.shot
					totals[:face_off_won] += stat.face_off_won
					totals[:face_off_lost] += stat.face_off_lost
					totals[:ground_ball] += stat.ground_ball
					totals[:interception] += stat.interception
					totals[:turnover] += stat.turnover
					totals[:caused_turnover] += stat.caused_turnover
				end

				if s.lacross_scorings.any?
					s.lacross_scorings.each do |stat|
						totals[:goal] += 1 if stat.scoretype == "Goal"
						totals[:assist] += 1 if stat.scoretype == "Assist"
					end
				end
			end

			return totals
		end

		def goalietotals
			totals = Hash.new

			@stats.each do |s|
				if s.lacross_goalstats
					s.lacross_goalstats.each do |l|
						totals[:saves] += l.saves
						totals[:goals_allowed] += l.goals_allowed
						totals[:minutesplayed] += l.minutesplayed
					end
				end
			end

			return totals
		end

	end
end
