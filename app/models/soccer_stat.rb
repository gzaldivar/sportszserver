class SoccerStat
	include Mongoid::Document
	include Mongoid::Timestamps

	embeds_many :soccer_scorings
	embeds_many :soccer_penalties
	embeds_many :soccer_playerstats
	embeds_many :soccer_goalstats

	belongs_to :athlete
	belongs_to :soccer_game
	belongs_to :visitor_roster

  	def player_shots
    	shots = 0

    	soccer_playerstats.each do |s|
        	shots += s.shots
     	end

    	return shots
	end

	def player_cornerkicks
		cornerkicks = 0

		soccer_playerstats.each do |s|
	    	cornerkicks += s.cornerkick
		end

		return cornerkicks
	end

	def player_steals
		steals = 0

		soccer_playerstats.each do |s|
			steals += s.steals
		end

		return steals
	end

	def player_fouls
		fouls = 0

		soccer_playerstats.each do |s|
			fouls += s.fouls
		end

		return fouls
	end

	def player_goals
		soccer_scorings.count
	end

	def player_assists
		assists = 0

		soccer_scorings.each do |s|
			if s.assist
				assists += 1
			end
		end

		return assists
	end

	def player_penalties
		soccer_penalties.count
	end

	def player_saves
		saves = 0

		soccer_goalstats.each do |s|
			saves += s.saves
		end

		return saves
	end

	def player_goals_allowed
		goals_allowed = 0

		soccer_goalstats.each do |s|
			goals_allowed += s.goals_allowed
		end

		return goals_allowed		
	end

	def player_minutes_played
		minutes_played = 0

		soccer_goalstats.each do |s|
			minutes_played += s.minutes_played
		end

		return minutes_played
	end
	
end
