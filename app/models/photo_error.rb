class PhotoError
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :error_message, type: String
  field :modelname, type: String
  field :modelid, type: String
  field :sport, type: String
  
  validates_presence_of :error_message
  validates_presence_of :modelname
  validates_presence_of :modelid
  validates_presence_of :sport
  
end
