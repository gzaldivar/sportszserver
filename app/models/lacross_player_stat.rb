class LacrossPlayerStat
	include Mongoid::Document

    field :shot, type: Integer
    field :face_off_won, type: Integer
    field :face_off_lost, type: Integer
    field :ground_ball, type: Integer
    field :interception, type: Integer
    field :turnover, type: Integer
    field :caused_turnover, type: Integer 			# STICK CHECK, BLOCKS, DRAWN CHARGE
	field :period, type: Integer, default: 1

    embedded_in :lacrosstat

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :shot, greater_than_or_equal_to: 0
	validates_numericality_of :face_off_won, greater_than_or_equal_to: 0
	validates_numericality_of :face_off_lost, greater_than_or_equal_to: 0
	validates_numericality_of :ground_ball, greater_than_or_equal_to: 0
	validates_numericality_of :interception, greater_than_or_equal_to: 0
	validates_numericality_of :turnover, greater_than_or_equal_to: 0
	validates_numericality_of :caused_turnover, greater_than_or_equal_to: 0
	validates_numericality_of :period, greater_than_or_equal_to: 0

end