class SoccerGame
	include Mongoid::Document
    include Mongoid::Timestamps

    field :socceroppsog, type: Integer, default: 0
    field :socceroppck, type: Integer, default: 0
    field :socceroppsaves, type: Integer, default: 0
    field :socceroppfouls, type: Integer, default: 0

    field :homefouls, type: Integer, default: 0
    field :visitorfouls, type: Integer, default: 0
    field :homeoffsides, type: Integer, default: 0
    field :visitoroffsides, type: Integer, default: 0

    field :homeplayers, type: Array
    field :visitorplayers, type: Array

	embedded_in :gameschedule

	has_many :soccer_stats, dependent: :destroy
	has_one :visiting_team

    validates_numericality_of :socceroppfouls, greater_than_or_equal_to: 0
    validates_numericality_of :socceroppck, greater_than_or_equal_to: 0
    validates_numericality_of :socceroppsaves, greater_than_or_equal_to: 0
    validates_numericality_of :socceroppfouls, greater_than_or_equal_to: 0

    validates_numericality_of :homefouls, greater_than_or_equal_to: 0
    validates_numericality_of :visitorfouls, greater_than_or_equal_to: 0
    validates_numericality_of :homeoffsides, greater_than_or_equal_to: 0
    validates_numericality_of :visitoroffsides, greater_than_or_equal_to: 0

end