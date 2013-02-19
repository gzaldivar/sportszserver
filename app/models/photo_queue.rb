class PhotoQueue
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :modelname, type: String
  field :modelid, type: String
  field :sport, type: String
  
  index(  { modelid: 1 }, { unique: false } )
  
  validates_presence_of :modelname
  validates_presence_of :modelid
  validates_presence_of :sport
end
