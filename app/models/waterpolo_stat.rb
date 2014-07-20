class WaterpoloStat
	include Mongoid::Document
	include Mongoid::Timestamps

	embeds_many :waterpolo_scorings
	embeds_many :waterpolo_penalties
	embeds_many :waterpolo_playerstats
	embeds_many :waterpolo_goalstats

	belongs_to :athlete
	belongs_to :waterpolo_game

  	def player_shots
    	shots = 0

    	waterpolo_playerstats.each do |s|
        	shots += s.shots
     	end

    	return shots
	end

	def player_steals
		steals = 0

		waterpolo_playerstats.each do |s|
			steals += s.steals
		end

		return steals
	end

	def player_fouls
		fouls = 0

		waterpolo_playerstats.each do |s|
			fouls += s.fouls
		end

		return fouls
	end

	def player_goals
		waterpolo_scorings.count
	end

	def player_assists
		assists = 0

		waterpolo_scorings.each do |s|
			if s.assist
				assists += 1
			end
		end

		return assists
	end

	def player_penalties
		waterpolo_penalties.count
	end

	def player_saves
		saves = 0

		waterpolo_goalstats.each do |s|
			saves += s.saves
		end

		return saves
	end

	def player_goals_allowed
		goals_allowed = 0

		waterpolo_goalstats.each do |s|
			goals_allowed += s.goals_allowed
		end

		return goals_allowed		
	end

	def player_minutes_played
		minutes_played = 0

		waterpolo_goalstats.each do |s|
			minutes_played += s.minutes_played
		end

		return minutes_played
	end

end
