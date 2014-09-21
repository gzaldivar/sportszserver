class HockeyPenalty
	include Mongoid::Document
	include Mongoid::Timestamps

	field :infraction, type: String, default: ""
	field :gametime, type: String, default: "00:00"
	field :penaltytime, type: String, default: "0:00"
	field :period, type: Integer, default: 1

	embedded_in :hockey_stat

	index( { period: 1 }, { unique: true } )

	validates_numericality_of :period, greater_than_or_equal_to: 0

end