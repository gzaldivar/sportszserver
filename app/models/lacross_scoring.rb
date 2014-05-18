class LacrossScoring
	include Mongoid::Document

    field :gamettime, type: Integer
    field :scoretype, type: String
    field :scorecode, type: String, default: ""
    field :period, type: Integer, default: 1

    embedded_in :lacrosstat

	index({ period: 1 }, { unique: true } )

    validates :scoretype, presence: true, format: { with: /Goal|Assist/ }
    validates :scorecode, presence: true, format: { with: /B, C, D, F, O, X/ }
	validates_numericality_of :period, greater_than_or_equal_to: 0

 end
