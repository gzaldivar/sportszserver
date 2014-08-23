class Alert
	include Mongoid::Document
	include Mongoid::Timestamps

	after_save :sendNotifications

	field :message, type: String
	field :stat_football, type: String
	field :users, type: Array, default: []
	field :teamusers, type: Array, default: []

	belongs_to :sport
 	belongs_to :team
	belongs_to :athlete
	belongs_to :blog
	belongs_to :photo
	belongs_to :videoclip

	belongs_to :gamelog
	belongs_to :lacross_scoring
	
 	belongs_to :basketball_stat
	belongs_to :soccer
	belongs_to :soccer_scoring
	belongs_to :waterpolo_scoring
	belongs_to :hockey_scoring

	belongs_to :football_defense
	belongs_to :football_kicker
	belongs_to :football_passing
	belongs_to :football_place_kicker
	belongs_to :football_punter
	belongs_to :football_receiving
	belongs_to :football_returner
	belongs_to :football_rushing

	validates :stat_football, format: { with: /Defense|Passing|Receiving|Kicker|Returner|Rushing|Place Kicker|Punter/ }, 
								allow_nil: true, allow_blank: true

	def teamHasScoreAlerts(team)
		if self.gamelog and team.id.to_s == self.team_id.to_s
			return true
		else
			return false
		end
	end

	def getGame
		Gameschedule.find(Gamelog.find(self.gamelog).gameschedule_id)
	end

	private

		def sendNotifications
    		Resque.enqueue(SendApnNotification, self.id)
		end

end
