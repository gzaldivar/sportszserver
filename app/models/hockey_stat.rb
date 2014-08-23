class HockeyStat
	include Mongoid::Document
	include Mongoid::Timestamps

	embeds_many :hockey_scorings
	embeds_many :hockey_penalties
	embeds_many :hockey_playerstats
	embeds_many :hockey_goalstats

	belongs_to :athlete
	belongs_to :hockey_game
	belongs_to :visitor_roster

  	def player_shots
    	shots = 0

    	hockey_playerstats.each do |s|
        	shots += s.shots
     	end

    	return shots
	end

	def player_minutes
		minutes = 0

		hockey_penalties.each do |h|
			minutes += h.minutes
		end

		return minutes
	end

	def player_goals
		hockey_scorings.count
	end

	def player_assists
		assists = 0

		hockey_scorings.each do |s|
			if s.assist
				assists += 1
			end
		end

		return assists
	end

	def player_penalties
		hockey_penalties.count
	end

	def player_saves
		saves = 0

		hockey_goalstats.each do |s|
			saves += s.saves
		end

		return saves
	end

	def player_goals_allowed
		goals_allowed = 0

		hockey_goalstats.each do |s|
			goals_allowed += s.goals_allowed
		end

		return goals_allowed		
	end

	def player_minutes_played
		minutes_played = 0

		hockey_goalstats.each do |s|
			minutes_played += s.minutes_played
		end

		return minutes_played
	end

end
