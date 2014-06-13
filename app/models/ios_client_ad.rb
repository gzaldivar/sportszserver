class IosClientAd
	include Mongoid::Document

	field :referencename, type: String
	field :productid, type: String
	field :adtype, type: String
	field :appleid, type: String

	belongs_to :admin
end