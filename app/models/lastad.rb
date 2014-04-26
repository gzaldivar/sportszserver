class Lastad
	include Mongoid::Document
	include Mongoid::Timestamps

	field :adlevel, type: Integer
	field :adindex, type: Integer
	field :levelarray, type: Array
	field :pricearray, type: Array

	belongs_to :sport

end
