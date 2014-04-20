class Adinventory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :price, type: Integer
  field :adlevelname, type: String
  field :active, type: Boolean

  has_many :sportadinv

end
