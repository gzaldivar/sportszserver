class FootballPunter
	include Mongoid::Document
	include Mongoid::Timestamps

	field	:punts, type: Integer, default: 0
	field	:punts_blocked, type: Integer, default: 0
	field	:punts_yards, type: Integer, default: 0
	field 	:punts_long, type: Integer, default: 0

	belongs_to :athlete
	belongs_to :gameschedule
	has_many :alerts, dependent: :destroy
	
	validates_numericality_of :punts, greater_than_or_equal_to: 0
	validates_numericality_of :punts_blocked, greater_than_or_equal_to: 0
	validates_numericality_of :punts_yards, greater_than_or_equal_to: 0
	validates_numericality_of :punts_long, greater_than_or_equal_to: 0

	def puntsaverage
		if punts > 0
			return Float(punts_yards / punts)
		else
			return 0
		end
	end
end
