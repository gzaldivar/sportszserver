class LacrossPlayerStat
	include Mongoid::Document

    field :shot, type: Array, default: []

    field :face_off_won, type: Integer, default: 0
    field :face_off_lost, type: Integer, default: 0
	field :face_off_violation, type: Integer, default: 0

    field :ground_ball, type: Integer, default: 0
    field :interception, type: Integer, default: 0

    field :turnover, type: Integer, default: 0
    field :caused_turnover, type: Integer 	, default: 0		# STICK CHECK, BLOCKS, DRAWN CHARGE

    field :steals, type: Integer, default: 0

	field :period, type: Integer, default: 1

    embedded_in :lacrosstat

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :ground_ball, greater_than_or_equal_to: 0
	validates_numericality_of :interception, greater_than_or_equal_to: 0
	validates_numericality_of :turnover, greater_than_or_equal_to: 0
	validates_numericality_of :caused_turnover, greater_than_or_equal_to: 0
	validates_numericality_of :period, greater_than_or_equal_to: 0
	validates_numericality_of :face_off_won, greater_than_or_equal_to: 0
	validates_numericality_of :face_off_lost, greater_than_or_equal_to: 0
	validates_numericality_of :face_off_violation, greater_than_or_equal_to: 0

end