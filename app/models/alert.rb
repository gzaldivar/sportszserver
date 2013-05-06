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

  	belongs_to :football_stat
	belongs_to :gamelog

	validates :stat_football, format: { with: /Defense|Passing|Receiving|Kicker|Returner|Rushing/ }, allow_nil: true, allow_blank: true

end
