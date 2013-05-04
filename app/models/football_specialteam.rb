class FootballSpecialteam
  include Mongoid::Document
  include Mongoid::Timestamps

  include SendAlert

  after_save :send_alerts
  
	field	:fgattempts, type: Integer, default: 0
	field	:fgmade, type: Integer, default: 0
	field	:fgblocked, type: Integer, default: 0
	field	:fglong, type: Integer, default: 0

	field	:xpattempts, type: Integer, default: 0
	field	:xpmade, type: Integer, default: 0
	field	:xpmissed, type: Integer, default: 0
	field	:xpblocked, type: Integer, default: 0

	field	:koattempts, type: Integer, default: 0
	field	:kotouchbacks, type: Integer, default: 0
	field	:koreturned, type: Integer, default: 0
#	field	:koreturn_average, type: Float

	field	:punts, type: Integer, default: 0
	field	:punts_blocked, type: Integer, default: 0
	field	:punts_yards, type: Integer, default: 0
	field 	:punts_long, type: Integer, default: 0

	field	:punt_return, type: Integer, default: 0
	field	:punt_returntd, type: Integer, default: 0
	field	:punt_returnlong, type: Integer, default: 0
	field	:punt_returnyards, type: Integer, default: 0
	
	field	:koreturns, type: Integer, default: 0
	field	:kotd, type: Integer, default: 0
	field	:kolong, type: Integer, default: 0
	field	:koyards, type: Integer, default: 0
	
	embedded_in :football_stat
	
	validates_numericality_of :fgattempts, greater_than_or_equal_to: 0
	validates_numericality_of :fgmade, greater_than_or_equal_to: 0
	validates_numericality_of :fgblocked, greater_than_or_equal_to: 0
	validates_numericality_of :fglong, greater_than_or_equal_to: 0

	validates_numericality_of :xpattempts, greater_than_or_equal_to: 0
	validates_numericality_of :xpmade, greater_than_or_equal_to: 0
	validates_numericality_of :xpmissed, greater_than_or_equal_to: 0
	validates_numericality_of :xpblocked, greater_than_or_equal_to: 0

	validates_numericality_of :koattempts, greater_than_or_equal_to: 0
	validates_numericality_of :kotouchbacks, greater_than_or_equal_to: 0
	validates_numericality_of :koreturned, greater_than_or_equal_to: 0
#	validates_numericality_of :koreturn_average, greater_than_or_equal_to: 0

	validates_numericality_of :punts, greater_than_or_equal_to: 0
	validates_numericality_of :punts_blocked, greater_than_or_equal_to: 0
	validates_numericality_of :punts_yards, greater_than_or_equal_to: 0
	validates_numericality_of :punts_long, greater_than_or_equal_to: 0

	validates_numericality_of :punt_return, greater_than_or_equal_to: 0
	validates_numericality_of :punt_returntd, greater_than_or_equal_to: 0
	validates_numericality_of :punt_returnlong, greater_than_or_equal_to: 0
	validates_numericality_of :punt_returnyards, greater_than_or_equal_to: 0

	validates_numericality_of :koreturns, greater_than_or_equal_to: 0
	validates_numericality_of :kotd, greater_than_or_equal_to: 0
	validates_numericality_of :kolong, greater_than_or_equal_to: 0
	validates_numericality_of :koyards, greater_than_or_equal_to: 0

	private

	    def send_alerts
	      send_stat_alerts(self.football_stat.athlete.sport, self.football_stat.athlete, self.football_stat.gameschedule, "Special Teams Statistics Updated")
	    end

end
