class LacrossScoring
	include Mongoid::Document
	include Mongoid::Timestamps

	after_save :send_notification

    field :gametime, type: String
    field :assist, type: String
    field :scorecode, type: String, default: ""
    field :period, type: Integer, default: 1

    embedded_in :lacrosstat
    has_many :photos, dependent: :nullify
    has_many :videoclips, dependent: :nullify
    has_one :alert, dependent: :destroy

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
			if lacrosstat.athlete_id
				log = log + ', Assist ' + Athlete.find(assist).numlogname
			else
				log = log + ', Assist ' + VisitorRoster.find(assist).numlogname
			end
		end

		return log
	end

	private

		def send_notification
 			sport = self.lacrosstat.athlete.sport
			team = sport.teams.find(self.lacrosstat.athlete.team_id)
        	Alert.create!(laccross_scoring_id: self.id, sport_id: sport.id, users: team.fans, message: self.scorelog, team_id: team.id)
		end
 end
