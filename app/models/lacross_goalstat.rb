class LacrossGoalstat
	include Mongoid::Document

    field :saves, type: Integer, default: 0
    field :minutesplayed, type: Integer, default: 0
    field :goals_allowed, type: Integer, default: 0
    field :period, type: Integer, default: 1

	embedded_in :lacrosstat

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :period, greater_than_or_equal_to: 0

	def save_percentage
		self.save/(self.save + self.goal)
	end

	def goal_average
		(self.goals_allowed * 60) / self.minutesplayed
	end

end