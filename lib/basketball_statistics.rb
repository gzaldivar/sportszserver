module BasketballStatistics

	mattr_accessor :totals

	class Basketballstats

		attr_accessor :stats

		def initialize(sport, anobject)
			@playergame = anobject
			thestats = anobject.basketball_stats

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
						@stats << BasketballStat.new(gameschedule_id: g.id, athlete_id: anobject.id)
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
						@stats << BasketballStat.new(gameschedule_id: anobject.id, athlete_id: p.id)
					end
				end
			end

#			@stats.sort_by! { |obj| obj.attempts }.reverse!
		end

		def stattotals
			if @playergame.kind_of?(Athlete)
				totals = BasketballStat.new(athlete_id: @playergame.id)
			else
				totals = BasketballStat.new(gameschedule_id: @playergame.id)
			end

			@stats.each do |s|
				totals.twoattempt += s.twoattempt
				totals.twomade += s.twomade
  				totals.threeattempt += s.threeattempt
 				totals.threemade += s.threemade
 				totals.ftmade += s.ftmade
				totals.ftattempt += s.ftattempt
				totals.fouls += s.fouls
				totals.assists += s.assists
				totals.steals += s.steals
				totals.blocks += s.blocks
				totals.offrebound += s.offrebound
				totals.defrebound += s.defrebound
				totals.turnovers += s.turnovers
			end

			return totals
		end
	end

end
