class WaterpoloGoalstat
	include Mongoid::Document
	include Mongoid::Timestamps

    field :saves, type: Integer, default: 0
    field :minutesplayed, type: Integer, default: 0
    field :goals_allowed, type: Integer, default: 0
    field :period, type: Integer, default: 1

	embedded_in :waterpolo_stat

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :period, greater_than_or_equal_to: 0
	validates_numericality_of :saves, greater_than_or_equal_to: 0
	validates_numericality_of :goals, greater_than_or_equal_to: 0
	validates_numericality_of :minutesplayed, greater_than_or_equal_to: 0

	def save_percentage
		self.save/(self.saves + self.goals_allowed)
	end

	def goal_average
		(self.goals_allowed * 60) / self.minutesplayed
	end

end