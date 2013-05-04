class FootballReturner
  	include Mongoid::Document

	include SendAlert

	after_save :send_alerts
  
  	field	:punt_return, type: Integer, default: 0
	field	:punt_returntd, type: Integer, default: 0
	field	:punt_returnlong, type: Integer, default: 0
	field	:punt_returnyards, type: Integer, default: 0
	
	field	:koreturns, type: Integer, default: 0
	field	:kotd, type: Integer, default: 0
	field	:kolong, type: Integer, default: 0
	field	:koyards, type: Integer, default: 0
	
	embedded_in :football_stat
	
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
