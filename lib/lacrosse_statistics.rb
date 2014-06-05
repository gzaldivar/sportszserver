module LacrosseStatistics

#	mattr_accessor :totals

	def lacrossehomescore(game)
		score = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				for i in 0 .. 4
					score[i] += l.lacross_scorings.where(period: i + 1).count
				end
			end
		end

		return score
	end

	def lacrosshomeassists(game)
		score = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				for i in 0 .. 4
					score[i] += l.lacross_scorings.where(:assist.exists => true, period: i + 1).count
				end
			end
		end

		return score
	end

	def lacrosshompenalties(game)
		penalty = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				for i in 1 .. 5
					penalty += l.lacross_penalties.where(period: i).count
				end
			end
		end

		return penalty
	end

	def lacrossehomesteals(game)
		steals = 0

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				for i in 1 .. 5
					stats = l.lacross_player_stats.find_by(period: i)
					if stats
						steals += stats.steals
					end
				end
			end
		end

		return steals
	end

	def lacrossehometurnovers(game)
		turnovers = 0

		if game.lacross_game and game.lacross_game.lacrosstats
			game.lacross_game.lacrosstats.each do |l|
				for i in 1 .. 5
					stats = l.lacross_player_stats.find_by(period: i)
					if stats
						turnovers += stats.turnover
					end
				end
			end
		end

		return turnovers
	end

	def lacrossevisitorscore(game)
		score = Array.new(5) { 0 }

		if game.lacross_game and game.lacross_game.visiting_team
			game.lacross_game.visiting_team.visitor_rosters.each do |v|
				if v.lacrosstat
					for i in 0 .. 4
						score[i] += v.lacrosstat.lacross_scorings.where(period: i + 1).count
					end
				end
			end
		end

		return score
	end

	def lacrossevisitorsteals(game)
		steals = 0

		if game.lacross_game and game.lacross_game.visiting_team
			game.lacross_game.visiting_team.visitor_rosters.each do |v|
				if v.lacrosstat
					for i in 1 .. 5
						stats = v.lacrosstat.lacross_player_stats.find_by(period: i)
						if stats
							steals += stats.steals
						end
					end
				end
			end
		end

		return steals
	end

	def lacrossevisitorturnovers(game)
		turnovers = 0

		if game.lacross_game and game.lacross_game.visiting_team
			game.lacross_game.visiting_team.visitor_rosters.each do |v|
				if v.lacrosstat
					for i in 1 .. 5
						stats = v.lacrosstat.lacross_player_stats.find_by(period: i)
						if stats
							turnovers += stats.turnover
						end
					end
				end
			end
		end

		return turnovers
	end

	def lacrosse_clearing_percentage(game)
		game.clears.inject{|sum,x| sum + x }/(game.clears.inject{|sum,x| sum + x} + game.failedclears.inject{|sum,x| sum + x})
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
					goals += stat.lacross_scorings.count
					shots += stat.lacross_player_stats.shots.count
				end
			end
		else								# computing stats for game from players
			sport.athletes.where(team_id: anobject.team_id).each do |athlete|
				stat = athlete.lacrosstats.find_by(gameschedule_id: anobject.id)

				if !stat.nil?
					goals += stat.lacross_scorings.count
					shots += l.lacross_player_stats.shot.count
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
						@stats << Lacrosstat.new(lacross_game_id: g.lacross_game_id, athlete_id: anobject.id)
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
							@stats << Lacrosstat.new(lacross_game_id: anobject.lacross_game.id, athlete_id: p.id)
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
						thestats[:shot] = p.shot.count
						thestats[:face_off_won] = p.face_off_won
						thestats[:face_off_lost] = p.face_off_lost
						thestats[:ground_ball] = p.ground_ball
						thestats[:interception] = p.interception
						thestats[:turnover] = p.turnover
						thestats[:caused_turnover] = p.caused_turnover
						thestats[:steals] = p.steals
					end
				else
					thestats = { :shot => 0, :face_off_won => 0, :face_off_lost => 0, :ground_ball => 0, :interception => 0, :turnover => 0, 
								:caused_turnover => 0, :steals => 0 }
				end

				if s.lacross_scorings.any?
					goals = 0
					assists = 0

					s.lacross_scorings.each do |stat|
						goals += 1 
						assists += 1 if stat.assist
					end

					thestats[:goal] = goals
					thestats[:assist] = assists
				else
					thestats[:goal] = 0
					thestats[:assist] = 0
				end

				thestats[:athlete_id] = s.athlete_id.to_s
#				thestats[:gameschedule_id] = s.lacross_game.gameschedule_id.to_s

				gamestats << thestats
			end


			return gamestats
		end

		def playertotals
			totals = { :shot => 0, :face_off_won => 0, :face_off_lost => 0, :ground_ball => 0, :interception => 0, :turnover => 0, 
						:caused_turnover => 0, :steals => 0, :goal => 0, :assist => 0 }

			@stats.each do |s|
				s.lacross_player_stats.each do |stat|
					totals[:shot] += stat.shot.count
					totals[:face_off_won] += stat.face_off_won
					totals[:face_off_lost] += stat.face_off_lost
					totals[:ground_ball] += stat.ground_ball
					totals[:interception] += stat.interception
					totals[:turnover] += stat.turnover
					totals[:caused_turnover] += stat.caused_turnover
					totals[:steals] += stat.steals
				end

				if s.lacross_scorings.any?
					s.lacross_scorings.each do |stat|
						totals[:goal] += 1
						totals[:assist] += 1 if stat.assist
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
