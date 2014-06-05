class LacrossScoring
	include Mongoid::Document

    field :gametime, type: String
    field :assist, type: String
    field :scorecode, type: String, default: ""
    field :period, type: Integer, default: 1

    embedded_in :lacrosstat
    has_many :photos, dependent: :nullify
    has_many :videoclips, dependent: :nullify

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :period, greater_than_or_equal_to: 0

	scope :by_period, order_by(period: :asc, gametime: :desc) 

	def scorelog
		if lacrosstat.athlete_id
			log = gametime + ' - Goal ' + Athlete.find(lacrosstat.athlete_id).numlogname
		else
			log = gametime + ' - Goal ' + VisitorRoster.find(lacrosstat.visitor_roster_id).numlogname
		end

		if assist
			log = log + ', Assist ' + Athlete.find(assist).numlogname
		end

		return log
	end
 end
