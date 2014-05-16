class LacrossGame
	include Mongoid::Document
	include Mongoid::Timestamps

	# Lacrosse fields
	field :lacrosse_clears, type: Integer, default: 0
	field :lacrosse_badclears, type: Integer, default: 0

	embedded_in :lacross

	has_many :lacrosses, dependent: :destroy

end