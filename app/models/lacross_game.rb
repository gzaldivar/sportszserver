class LacrossGame
	include Mongoid::Document

	# Lacrosse fields
	field :lacrosse_clears, type: Integer, default: 0
	field :lacrosse_badclears, type: Integer, default: 0
    field :free_position_sog, type: Integer

    field :homepenaltybox, type: Hash
    field :visitorpenaltybox, type: Hash

    field :home_1stperiod_timeouts, type: Array.new(3) { "" }
    field :home_2ndperiod_timeouts, type: Array.new(3) { "" }
    field :visitor_1stperiod_timeouts, type: Array.new(3) { "" }
    field :visitor_1stperiod_timeouts, type: Array.new(3) { "" }

	embedded_in :gameschedule

	has_many :lacrosstats, dependent: :destroy
	has_one :visiting_team
end