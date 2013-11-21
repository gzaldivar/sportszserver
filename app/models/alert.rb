class Alert
	include Mongoid::Document
	include Mongoid::Timestamps

	field :message, type: String
	field :stat_football, type: String

	belongs_to :athlete
	belongs_to :blog
	belongs_to :photo
	belongs_to :videoclip
	belongs_to :user
	belongs_to :sport

  	belongs_to :basketball_stat
	belongs_to :gamelog
	belongs_to :soccer

	belongs_to :football_defense
	belongs_to :football_kicker
	belongs_to :football_passing
	belongs_to :football_place_kicker
	belongs_to :football_punter
	belongs_to :football_receiving
	belongs_to :football_returner
	belongs_to :football_rushing

	validates :stat_football, format: { with: /Defense|Passing|Receiving|Kicker|Returner|Rushing|Place Kicker|Punter/ }, allow_nil: true, allow_blank: true

end
