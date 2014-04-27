class Sportadinv
	include Mongoid::Document
	include Mongoid::Timestamps

	attr_accessor :date_string
	
	field :price, type: Float
	field :adlevelname, type: String
	field :active, type: Boolean
	field :expiration, type: DateTime

	belongs_to :sport
	belongs_to :athlete
	has_many :sponsors

	def priceincents
		price * 100
	end

#	validates_numericality_of :price, greater_than_or_equal_to: 0, message: "Only numeric values allowed for price"
	validates :price, :format => {  :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality =>{:greater_than => 0}, 
	:presence => { :message => "Only numeric values allowed for price" }
end
