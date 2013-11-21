class FootballKicker
	include Mongoid::Document

	field	:koattempts, type: Integer, default: 0
	field	:kotouchbacks, type: Integer, default: 0
	field	:koreturned, type: Integer, default: 0
#	field	:koreturn_average, type: Float
	
  	belongs_to :athlete
	belongs_to :gameschedule
	has_many :alerts, dependent: :destroy
	
	validates_numericality_of :koattempts, greater_than_or_equal_to: 0
	validates_numericality_of :kotouchbacks, greater_than_or_equal_to: 0
	validates_numericality_of :koreturned, greater_than_or_equal_to: 0
#	validates_numericality_of :koreturn_average, greater_than_or_equal_to: 0

end
