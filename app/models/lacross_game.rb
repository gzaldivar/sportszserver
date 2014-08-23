class LacrossGame
	include Mongoid::Document
    include Mongoid::Timestamps

    field :clears, type: Array, default: []
    field :failedclears, type: Array, default: []
    field :visitor_clears, type: Array, default: []
    field :visitor_failedclears, type: Array, default: []

    field :free_position_sog, type: Integer
    
    field :extraman_fail, type: Array, default: []
    field :visitor_extraman_fail, type: Array, default: []

    field :home_penaltyone_number, type: Integer, default: 0
    field :home_penaltyone_minutes, type: Integer, default: 0
    field :home_penaltyone_seconds, type: Integer, default: 0
    field :home_penaltytwo_number, type: Integer, default: 0
    field :home_penaltytwo_minutes, type: Integer, default: 0
    field :home_penaltytwo_seconds, type: Integer, default: 0

    field :visitor_penaltyone_number, type: Integer, default: 0
    field :visitor_penaltyone_minutes, type: Integer, default: 0
    field :visitor_penaltyone_seconds, type: Integer, default: 0
    field :visitor_penaltytwo_number, type: Integer, default: 0
    field :visitor_penaltytwo_minutes, type: Integer, default: 0
    field :visitor_penaltytwo_seconds, type: Integer, default: 0

    field :home_1stperiod_timeouts, type: Array, default: []
    field :home_2ndperiod_timeouts, type: Array, default: []
    field :visitor_1stperiod_timeouts, type: Array, default: []
    field :visitor_2ndperiod_timeouts, type: Array, default: []

    field :visitor_score_period1, type: Integer, default: 0
    field :visitor_score_period2, type: Integer, default: 0
    field :visitor_score_period3, type: Integer, default: 0
    field :visitor_score_period4, type: Integer, default: 0
    field :visitor_score_periodOT1, type: Integer, default: 0

	embedded_in :gameschedule

	has_many :lacrosstats, dependent: :destroy
	has_one :visiting_team

end