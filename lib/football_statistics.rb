module FootballStatistics

	mattr_accessor :rushingyardtotals, :passingyardtotals, :receivingyardtotals, :turnovers

	def footballhomescore(sport, game)
		score = 0

		sport.athletes.where(team_id: game.team_id).each do |p|
			passscore = p.football_passings.find_by(gameschedule_id: game.id)
			if !passscore.nil?
				score += passscore.td * 6
				score += passscore.twopointconv * 2
			end
		end

		sport.athletes.where(team_id: game.team_id).each do |p|
			rushscore = p.football_rushings.find_by(gameschedule_id: game.id)
			if !rushscore.nil?
				score += rushscore.td * 6
				score += rushscore.twopointconv * 2
			end
		end

		sport.athletes.where(team_id: game.team_id).each do |p|
			defensescore = p.football_defenses.find_by(gameschedule_id: game.id)
			if !defensescore.nil?
				score += defensescore.int_td * 6
				score += defensescore.safety * 2
			end
		end

		sport.athletes.where(team_id: game.team_id).each do |p|
			returnsscore = p.football_returners.find_by(gameschedule_id: game.id)
			if !returnsscore.nil?
				score += returnsscore.kotd * 6
				score += returnsscore.punt_returntd * 6
			end
		end
		return score
	end

	def totalfirstdowns(sport, game)
		firstdowns = 0

		sport.athletes.where(team_id: game.team_id).each do |p|
			passstat = p.football_passings.find_by(gameschedule_id: game.id)
			if !passstat.nil?
				firstdowns += passstat.firstdowns
			end
		end

		sport.athletes.where(team_id: game.team_id).each do |p|
			rushstat = p.football_rushings.find_by(gameschedule_id: game.id)
			if !rushstat.nil?
				firstdowns += rushstat.firstdowns
			end
		end

		return firstdowns
	end

	def footballtotalyards(sport, game)
		totalyards = 0
		@@passingyardtotals = 0
		@@rushingyardtotals = 0
		@@receivingyardtotals = 0
		@@turnovers = 0

		sport.athletes.where(team_id: game.team_id).each do |p|
			passstat = p.football_passings.find_by(gameschedule_id: game.id)
			rushstat = p.football_rushings.find_by(gameschedule_id: game.id)
			recstat = p.football_rushings.find_by(gameschedule_id: game.id)

			if !passstat.nil?
				totalyards += passstat.yards
				@@passingyardtotals += passstat.yards
				@@turnovers += passstat.interceptions
			end

			if !rushstat.nil?
				totalyards += rushstat.yards
				@@rushingyardtotals += rushstat.yards
				@@turnovers += rushstat.fumbles_lost
			end

			if !recstat.nil?
				@@receivingyardtotals += recstat.yards
				@@turnovers += recstat.fumbles_lost
			end
		end

		return totalyards
	end

	class Passingstats

		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_passings

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballPassing.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballPassing.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def passingtotals
			if @playergame.kind_of?(Athlete)
				totals = FootballPassing.new(athlete_id: @playergame.id)
			else
				totals = FootballPassing.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.attempts += s.attempts
				totals.completions += s.completions
				totals.yards += s.yards
				totals.td += s.td
				totals.interceptions += s.interceptions
				totals.sacks += s.sacks
				totals.yards_lost += s.yards_lost
				totals.comp_percentage += s.comp_percentage
				totals.twopointconv += s.twopointconv
				totals.firstdowns += s.firstdowns
			end

		    if totals.completions > 0 and totals.attempts > 0
		    	totals.comp_percentage = Float(totals.completions) / Float(totals.attempts)
		    else
		    	totals.comp_percentage = Float(0)
		    end

			return totals
		end

		def gamefirstdowns
			if @playergame.kind_of?(Gameschedule)
				firstdowns = 0
				
				stats.each do |s|
					if s.id == @playergame.id
						firstdowns += s.firstdowns
					end
				end

				return firstdowns
			else
				return 0
			end
		end

	end

	class Rushingstats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_rushings

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballRushing.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballRushing.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def rushingtotals
			if @playergame.kind_of?(Athlete)
				totals = FootballRushing.new(athlete_id: @playergame.id)
			else
				totals = FootballRushing.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.attempts += s.attempts
				totals.yards += s.yards

				if totals.longest < s.longest
					totals.longest = s.longest
				end

				totals.td += s.td
				totals.fumbles += s.fumbles
				totals.fumbles_lost += s.fumbles_lost
				totals.twopointconv += s.twopointconv
				totals.firstdowns += s.firstdowns
 			end

		    if totals.attempts > 0 and totals.yards > 0 
		    	totals.average = Float(totals.yards) / Float(totals.attempts)
		    else
		    	totals.average = 0.0
		    end

			return totals
		end

		def gamefirstdowns
			if @playergame.kind_of?(Gameschedule)
				firstdowns = 0
				
				stats.each do |s|
					if s.id == @playergame.id
						firstdowns += s.firstdowns
					end
				end

				return firstdowns
			else
				return 0
			end
		end
	end

	class Receivingstats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_receivings

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballReceiving.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballReceiving.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def receivingtotals
			if @playergame.kind_of?(Athlete)
				totals = FootballReceiving.new(athlete_id: @playergame.id)
			else
				totals = FootballReceiving.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.receptions += s.receptions
				totals.yards += s.yards

				if totals.longest < s.longest
					totals.longest = s.longest
				end

				totals.td += s.td
				totals.fumbles += s.fumbles
				totals.fumbles_lost += s.fumbles_lost
				totals.twopointconv += s.twopointconv
			end

		    if totals.receptions > 0 and totals.yards > 0
		    	totals.average = Float(totals.yards) / Float(totals.receptions)
		    else
		      totals.average = 0.0
		    end

			return totals
		end
	end

	class Defensestats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_defenses

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballDefense.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballDefense.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def defensetotals
			if @playergame.kind_of?(Athlete)
				totals = FootballDefense.new(athlete_id: @playergame.id)
			else
				totals = FootballDefense.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.tackles += s.tackles
				totals.assists += s.assists
				totals.sacks += s.sacks
				totals.pass_defended += s.pass_defended
				totals.interceptions += s.interceptions
				totals.int_yards += s.int_yards

				if totals.int_long < s.int_long
					totals.int_long = s.int_long
				end

				totals.int_td += s.int_td
				totals.fumbles_recovered += s.fumbles_recovered
				totals.safety += s.safety
			end

			return totals
		end
	end

	class Placekickerstats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_place_kickers

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballPlaceKicker.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballPlaceKicker.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def placekickertotals
			if @playergame.kind_of?(Athlete)
				totals = FootballPlaceKicker.new(athlete_id: @playergame.id)
			else
				totals = FootballPlaceKicker.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.fgattempts += s.fgattempts
				totals.fgmade += s.fgmade
				totals.fgblocked += s.fgblocked

				if totals.fglong < s.fglong
					totals.fglong = s.fglong
				end

				totals.xpattempts = s.xpattempts
				totals.xpmade += s.xpmade
				totals.xpmissed += s.xpmissed
				totals.xpblocked += s.xpblocked
			end

			return totals
		end
	end

	class Returnerstats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_returners

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballReturner.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballReturner.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def returnertotals
			if @playergame.kind_of?(Athlete)
				totals = FootballReturner.new(athlete_id: @playergame.id)
			else
				totals = FootballReturner.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.punt_return += s.punt_return
				totals.punt_returntd += s.punt_returntd
				totals.punt_returnyards += s.punt_returnyards

				if totals.punt_returnlong < s.punt_returnlong
					totals.punt_returnlong = s.punt_returnlong
				end

				totals.koreturns += s.koreturns
				totals.kotd += s.kotd
				totals.koyards += s.koyards

				if totals.kolong < s.kolong
					totals.kolong = s.kolong
				end
			end

			return totals
		end
	end

	class Punterstats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_punters

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballPunter.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballPunter.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def puntertotals
			if @playergame.kind_of?(Athlete)
				totals = FootballPunter.new(athlete_id: @playergame.id)
			else
				totals = FootballPunter.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.punts += s.punts
				totals.punts_blocked += s.punts_blocked
				totals.punts_yards += s.punts_yards

				if totals.punts_long < s.punts_long
					totals.punts_long = s.punts_long
				end
			end

			return totals
		end
	end

	class Kickerstats
		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.football_kickers

			if anobject.kind_of?(Athlete)
				games = sport.teams.find(anobject.team_id).gameschedules

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
						@stats << FootballKicker.new(gameschedule_id: g.id, athlete_id: anobject.id)
					end
				end
			else
				players = sport.athletes.where(team_id: anobject.team_id)

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
						@stats << FootballKicker.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end
		end

		def kickertotals
			if @playergame.kind_of?(Athlete)
				totals = FootballKicker.new(athlete_id: @playergame.id)
			else
				totals = FootballKicker.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.koattempts += s.koattempts
				totals.kotouchbacks += s.kotouchbacks
				totals.koreturned += s.koreturned
			end

			return totals
		end
	end

end
