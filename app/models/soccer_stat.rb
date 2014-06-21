class SoccerStat
	include Mongoid::Document
	include Mongoid::Timestamps

	embeds_many :soccer_scorings
	embeds_many :soccer_penalties
	embeds_many :scocer_playerstats
	embeds_many :soccer_goalstats

	belongs_to :athlete
	belongs_to :soccer_game
end
