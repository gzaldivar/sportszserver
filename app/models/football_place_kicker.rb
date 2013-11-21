class FootballPlaceKicker
  include Mongoid::Document
  include Mongoid::Timestamps

	field	:fgattempts, type: Integer, default: 0
	field	:fgmade, type: Integer, default: 0
	field	:fgblocked, type: Integer, default: 0
	field	:fglong, type: Integer, default: 0

	field	:xpattempts, type: Integer, default: 0
	field	:xpmade, type: Integer, default: 0
	field	:xpmissed, type: Integer, default: 0
	field	:xpblocked, type: Integer, default: 0

	belongs_to :athlete
	belongs_to :gameschedule
	has_many :alerts, dependent: :destroy

	validates_numericality_of :fgattempts, greater_than_or_equal_to: 0
	validates_numericality_of :fgmade, greater_than_or_equal_to: 0
	validates_numericality_of :fgblocked, greater_than_or_equal_to: 0
	validates_numericality_of :fglong, greater_than_or_equal_to: 0

	validates_numericality_of :xpattempts, greater_than_or_equal_to: 0
	validates_numericality_of :xpmade, greater_than_or_equal_to: 0
	validates_numericality_of :xpmissed, greater_than_or_equal_to: 0
	validates_numericality_of :xpblocked, greater_than_or_equal_to: 0
end
