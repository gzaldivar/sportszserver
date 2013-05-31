class PassingPlay
	include Mongoid::Document
	include Mongoid::Timestamps

	field :score, type: String
	field :receiver, type: String
	field :time, type: String
	field :quarter, type: String
	field :yards, type: Integer, default: 0

	embedded_in :football_passing

    validates_numericality_of :yards, greater_than_or_equal_to: 0

    def logentry
    	self.football_passing.football_stat.athlete.logname + " " + self.yards.to_s + " yards to " + Athlete.find(self.receiver).logname
	end

end
