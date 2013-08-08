class PhotoQueue
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :modelname, type: String
  field :modelid, type: String
  field :filename, type: String
  field :filetype, type: String
  field :filepath, type: String
  
  belongs_to :sport
  
  index(  { modelid: 1 }, { unique: false } )
  
  validates_presence_of :modelname
  validates_presence_of :modelid
  validates_presence_of :sport
end
