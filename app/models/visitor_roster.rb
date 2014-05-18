class VisitorRoster
	include Mongoid::Document

	field :number, type: Integer
	field :lastname, type: String
	field :firstname, type: String
	field :position, type: String

	has_one :lacrosstat, dependent: :destroy

	belongs_to :visiting_team
	
end