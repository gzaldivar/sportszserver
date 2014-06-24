class WaterpoloStat
	include Mongoid::Document
	include Mongoid::Timestamps

	embeds_many :waterpolo_scorings
	embeds_many :waterpolo_penalties
	embeds_many :waterpolo_playerstats
	embeds_many :waterpolo_goalstats

	belongs_to :athlete
	belongs_to :waterpolo_game
end
