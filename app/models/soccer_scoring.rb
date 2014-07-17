class SoccerScoring
	include Mongoid::Document
	include Mongoid::Timestamps

	after_save :send_notification

    field :gametime, type: String
    field :assist, type: String
    field :period, type: Integer, default: 1

    embedded_in :soccer_stat
    has_many :photos, dependent: :nullify
    has_many :videoclips, dependent: :nullify
    has_one :alert, dependent: :destroy

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :period, greater_than_or_equal_to: 0

	scope :by_period, order_by(period: :asc, gametime: :desc) 

	def scorelog
		if soccer_stat.athlete_id
			log = gametime + ' - Goal ' + Athlete.find(soccer_stat.athlete_id).numlogname
		else
			log = gametime + ' - Goal ' + VisitorRoster.find(soccer_stat.visitor_roster_id).numlogname
		end

		if assist and !assist.blank?
			if soccer_stat.athlete_id
				log = log + ', Assist ' + Athlete.find(assist).numlogname
			else
				log = log + ', Assist ' + VisitorRoster.find(assist).numlogname
			end
		end

		return log
	end

	private

		def send_notification
			sport = self.soccer_stat.athlete.sport
			team = sport.teams.find(self.soccer_stat.athlete.team_id)
        	Alert.create!(soccer_scoring_id: self.id, sport_id: sport.id, users: team.fans, message: self.scorelog, team_id: team.id)
		end
end