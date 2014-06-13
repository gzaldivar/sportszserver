class IosClientAd
	include Mongoid::Document

	field :referencename, type: String
	field :productid, type: String
	field :adtype, type: String
	field :appleid, type: String
	field :price, type: Float, default: 0.0

	belongs_to :admin
end