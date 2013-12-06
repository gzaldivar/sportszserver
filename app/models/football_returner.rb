class FootballReturner
  	include Mongoid::Document
  	include Mongoid::Timestamps
  
  	field	:punt_return, type: Integer, default: 0
	field	:punt_returntd, type: Integer, default: 0
	field	:punt_returnlong, type: Integer, default: 0
	field	:punt_returnyards, type: Integer, default: 0
	
	field	:koreturns, type: Integer, default: 0
	field	:kotd, type: Integer, default: 0
	field	:kolong, type: Integer, default: 0
	field	:koyards, type: Integer, default: 0
	
  	belongs_to :athlete
	belongs_to :gameschedule
	has_many :alerts, dependent: :destroy
	has_many :gamelogs, dependent: :destroy
	
	validates_numericality_of :punt_return, greater_than_or_equal_to: 0
	validates_numericality_of :punt_returntd, greater_than_or_equal_to: 0
	validates_numericality_of :punt_returnlong, greater_than_or_equal_to: 0
	validates_numericality_of :punt_returnyards, greater_than_or_equal_to: 0

	validates_numericality_of :koreturns, greater_than_or_equal_to: 0
	validates_numericality_of :kotd, greater_than_or_equal_to: 0
	validates_numericality_of :kolong, greater_than_or_equal_to: 0
	validates_numericality_of :koyards, greater_than_or_equal_to: 0

end
