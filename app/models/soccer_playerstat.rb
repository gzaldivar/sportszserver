class SoccerPlayerstat
	include Mongoid::Document
	include Mongoid::Timestamps

  	field :shots, type: Integer, default: 0
  	field :steals, type: Integer, default: 0
  	field :cornerkick, type: Integer, default: 0
    field :fouls, type: Integer, default: 0
    field :period, type: Integer, default: 1

    embedded_in :soccer_stat

    index({ period: 1 }, { unique: true } )

  	validates_numericality_of :shots, greater_than_or_equal_to: 0
  	validates_numericality_of :steals, greater_than_or_equal_to: 0
  	validates_numericality_of :cornerkick, greater_than_or_equal_to: 0
    validates_numericality_of :fouls, greater_than_or_equal_to: 0
    validates_numericality_of :period, greater_than_or_equal_to: 0

end