class Lacrosstat
 	include Mongoid::Document
 	include Mongoid::Timestamps

	belongs_to :athlete
	belongs_to :visitor_roster
	belongs_to :lacross_game

	embeds_many :lacross_scorings
	embeds_many :lacross_player_stats
	embeds_many :lacross_penalties
	embeds_many :lacross_goalstats

	has_many :gamelogs, dependent: :destroy

	def shooting_accuracy
		getgoals / self.shot
	end

	def points_per_game
		lacross_scorings.count
	end

	def getgoals
		lacross_scorings.each do |s|
			if s.scoretype == "Goal"
				goals += 1
			end
		end		
	end

	def getassists
		lacross_scorings.each do |s|
			if s.scoretype == "Assist"
				goals += 1
			end
		end		
	end
end