class SoccerPlayerstat
	include Mongoid::Document
	include Mongoid::Timestamps

  	field :shotstaken, type: Integer, default: 0
  	field :steals, type: Integer, default: 0
  	field :cornerkick, type: Integer, default: 0

    embedded_in :soccer_stat

	index({ period: 1 }, { unique: true } )

  	validates_numericality_of :shotstaken, greater_than_or_equal_to: 0
  	validates_numericality_of :steals, greater_than_or_equal_to: 0
  	validates_numericality_of :cornerkick, greater_than_or_equal_to: 0

end