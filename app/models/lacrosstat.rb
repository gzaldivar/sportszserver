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

	def points_per_game
		lacross_scorings.count
	end

end