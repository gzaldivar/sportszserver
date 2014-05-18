class LacrossPenalty
	include Mongoid::Document

	field :penalty, type: String
	field :time, type: String
	field :gametime, type: String
	field :period, type: Integer, default: 1

	embedded_in :lacrosstat

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :penalty, greater_than_or_equal_to: 0

end