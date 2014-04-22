class Sportadinv
	include Mongoid::Document
	include Mongoid::Timestamps

	field :price, type: Float
	field :adlevelname, type: String
	field :active, type: Boolean
	field :expiration, type: DateTime

	belongs_to :sport
	has_many :sponsors

	def priceincents
		price * 100
	end

end
