class VisitingTeam
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Paperclip

	field :title, type: String
	field :mascot, type: String

	has_many :visitor_rosters, dependent: :destroy

	belongs_to :sport
	belongs_to :lacross_game
	
end