class FootballSpecialteam
  include Mongoid::Document
  include Mongoid::Timestamps
  
	field	:fgattempts, type: Integer 
	field	:fgmade, type: Integer
	field	:fgblocked, type: Integer 
	field	:fglong, type: Integer

	field	:xpattempts, type: Integer
	field	:xpmade, type: Integer
	field	:xpmissed, type: Integer
	field	:xpblocked, type: Integer

	field	:koattempts, type: Integer
	field	:kotouchbacks, type: Integer
	field	:koreturned, type: Integer
#	field	:koreturn_average, type: Float

	field	:punts, type: Integer
	field	:punts_blocked, type: Integer
	field	:punts_yards, type: Integer
	field 	:punts_long, type: Integer

	field	:punt_return, type: Integer
	field	:punt_returntd, type: Integer
	field	:punt_returnlong, type: Integer
	field	:punt_returnyards, type: Integer
	
	field	:koreturns, type: Integer
	field	:kotd, type: Integer
	field	:kolong, type: Integer
	field	:koyards, type: Integer
	
	embedded_in :football_stat
	
	validates_numericality_of :fgattempts, allow_nil: true
	validates_numericality_of :fgmade, allow_nil: true
	validates_numericality_of :fgblocked, allow_nil: true
	validates_numericality_of :fglong, allow_nil: true

	validates_numericality_of :xpattempts, allow_nil: true
	validates_numericality_of :xpmade, allow_nil: true
	validates_numericality_of :xpmissed, allow_nil: true
	validates_numericality_of :xpblocked, allow_nil: true

	validates_numericality_of :koattempts, allow_nil: true
	validates_numericality_of :kotouchbacks, allow_nil: true
	validates_numericality_of :koreturned, allow_nil: true
#	validates_numericality_of :koreturn_average, allow_nil: true

	validates_numericality_of :punts, allow_nil: true
	validates_numericality_of :punts_blocked, allow_nil: true
	validates_numericality_of :punts_yards, allow_nil: true
	validates_numericality_of :punts_long, allow_nil: true

	validates_numericality_of :punt_return, allow_nil: true
	validates_numericality_of :punt_returntd, allow_nil: true
	validates_numericality_of :punt_returnlong, allow_nil: true
	validates_numericality_of :punt_returnyards, allow_nil: true

	validates_numericality_of :koreturns, allow_nil: true
	validates_numericality_of :kotd, allow_nil: true
	validates_numericality_of :kolong, allow_nil: true
	validates_numericality_of :koyards, allow_nil: true
end
