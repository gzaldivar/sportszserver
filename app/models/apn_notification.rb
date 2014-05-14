class ApnNotification
	include Mongoid::Document
	include Mongoid::Timestamps

	field :token, type: String
	field :model, type: String
	field :name, type: String
	field :systemname, type: String
	field :systemversion, type: String
	field :bundleidentifier, type: String

	field :scorealerts, type: Boolean
	field :athletealerts, type: Boolean
	field :mediaalerts, type: Boolean
	field :blogalerts, type: Boolean

	belongs_to :user
	belongs_to :athlete
	belongs_to :team

	 index( { token: 1 }, { unique: true } )

end