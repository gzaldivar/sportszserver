class FootballSpecialTeams
  include Mongoid::Document
  include Mongoid::Timestamps
  
	field	:game, type: String
	field	:attempts, type: Integer
	field	:made. type: Integer
	field	:blocks, type: Integer
	field	:long, type: Integer
	field	:xpattempts, type: Integer
	field	:xpmade, type: Integer
	field	:xpblocked, type: Integer
	field	:kickoff_attempts, type: Integer
	field	:kickoff_touch_backs, type: Integer
	field	:kickoff_returned, type: Integer
	field	:kickoff_return_ydavg, type: Float
	field	:punts, type: Integer
	field	:punts_blocked, type: Integer
	field	:punts_yards, type: Integer
	field :punts_long, type: Integer
	field	:punt_return, type; Integer
	field	:punt_return_tds, type: Integer
	field	:punt_return_long, type: Integer
	field	:punt_return_yards, type: Integer
	field	:ko_returns, type: Integer
	field	:ko_tds, type: Integer
	field	:ko_long, type: Integer
	field	:ko_yards, type: Integer
	
	belongs_to :athlete, index: true
	
  index( { game: 1 }, { unique: false } )
  
  validates_presence_of :game
	validates_numericality_of :attempts, greater_than: 0
	validates_numericality_of :made
	validates_numericality_of :blocks
	validates_numericality_of :long
	validates_numericality_of :xpattempts
	validates_numericality_of :xpmade
	validates_numericality_of :xpblocked
	validates_numericality_of :kickoff_attempts
	validates_numericality_of :kickoff_touch_backs
	validates_numericality_of :kickoff_returned
	validates_numericality_of :kickoff_return_ydavg
	validates_numericality_of :punts
	validates_numericality_of :punts_blocked
	validates_numericality_of :punts_yards
	validates_numericality_of :punts_long
	validates_numericality_of :punt_return
	validates_numericality_of :punt_return_tds
	validates_numericality_of :punt_return_long
	validates_numericality_of :punt_return_yards
	validates_numericality_of :ko_returns
	validates_numericality_of :ko_tds
	validates_numericality_of :ko_long
	validates_numericality_of :ko_yards
end
