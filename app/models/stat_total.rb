class StatTotal

	attr_reader :homescore, :fouls

	def initialize(sport, game)
		@sport = sport
		@game = game
		@homescore = 0
		@fouls = 0
	end

	def basketball_home_totals
		begin
			players = @sport.athletes.where(team_id: @game.team_id)

			players.each do |p|
				puts p.id
				stats = p.basketball_stats.find_by(gameschedule_id: @game.id.to_s)
				if !stats.nil?
					@homescore += (stats.twomade * 2) + (stats.threemade * 3) + stats.ftmade
					@fouls += stats.fouls
				end
			end

			return @homescore
		rescue Exception => e
			throw "Error computing basketball totals"
		end
	end

	def soccer_home_score
		players = @sport.athletes.where(team_id: @game.team_id)

		players.each do |p|
			stats = p.soccers.find_by(gameschedule_id: @game.id.to_s)
			if !stats.nil?
				@homescore += stats.goals
			end
		end

		return @homescore
	end

	def football_totals
		players = @sport.athletes.where(team_id: @gameschedule_id.team_id)

		players.each do |p|
		end
	end
end