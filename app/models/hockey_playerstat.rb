class HockeyPlayerstat
	include Mongoid::Document
	include Mongoid::Timestamps

  	field :shots, type: Integer, default: 0
  	field :plusminus, type: Integer, default: 0
  	field :faceoffwon, type: Integer, default: 0
  	field :faceofflost, type: Integer, default: 0
  	field :timeonice, type: String, default: "00:00"
  	field :hits, type: Integer, default: 0
  	field :blockedshots, type: Integer, default: 0
    
    field :period, type: Integer, default: 1

    embedded_in :hockey_stat

    index({ period: 1 }, { unique: true } )

  	validates_numericality_of :shots, greater_than_or_equal_to: 0
    validates_numericality_of :period, greater_than_or_equal_to: 0
    validates_numericality_of :faceoffwon, greater_than_or_equal_to: 0
    validates_numericality_of :faceofflost, greater_than_or_equal_to: 0
    validates_numericality_of :hits, greater_than_or_equal_to: 0
    validates_numericality_of :blockedshots, greater_than_or_equal_to: 0

end