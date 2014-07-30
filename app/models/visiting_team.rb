class VisitingTeam
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paperclip

	field :title, type: String
	field :mascot, type: String

	has_many :visitor_rosters, dependent: :destroy

	belongs_to :sport
	belongs_to :lacross_game, dependent: :nullify
	belongs_to :soccer_game, dependent: :nullify
	belongs_to :water_polo_game, dependent: :nullify
	
	def getname
		title + " " + mascot
	end
end