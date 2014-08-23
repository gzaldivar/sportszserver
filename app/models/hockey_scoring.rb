class HockeyScoring
	include Mongoid::Document
	include Mongoid::Timestamps

	after_save :send_notification

    field :gametime, type: String
    field :assist, type: String			# player id
    field :assist_type, type: String, type: "Even Strength Assist"
    field :period, type: Integer, default: 1
    field :goaltype, type: String, default: "Even Strength"

    embedded_in :hockey_stat
    has_many :photos, dependent: :nullify
    has_many :videoclips, dependent: :nullify
    has_one :alert, dependent: :destroy

	index({ period: 1 }, { unique: true } )

	validates_numericality_of :period, greater_than_or_equal_to: 0

	scope :by_period, order_by(period: :asc, gametime: :desc) 

	def scorelog
		if hockey_stat.athlete_id
			log = gametime + ' - Goal ' + Athlete.find(hockey_stat.athlete_id).numlogname
		else
			log = gametime + ' - Goal ' + VisitorRoster.find(hockey_stat.visitor_roster_id).numlogname
		end

		if assist
			if hockey_stat.athlete_id
				log = log + ', Assist ' + Athlete.find(assist).numlogname
			else
				log = log + ', Assist ' + VisitorRoster.find(assist).numlogname
			end
		end

		return log
	end

	private

		def send_notification
			sport = self.hockey_stat.athlete.sport
			team = sport.teams.find(self.hockey_stat.athlete.team_id)
        	Alert.create!(hockey_scoring_id: self.id, sport_id: sport.id, users: team.fans, message: self.scorelog, team_id: team.id)
		end
 end
