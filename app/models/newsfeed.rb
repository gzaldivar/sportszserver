class Newsfeed
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  field   :title, 		type: String
  field   :news,		type: String
  field   :external_url, type: String
  field   :owner,   type: String
  field   :allsports,	type: Boolean
  
  belongs_to :sport
  belongs_to :athlete
  belongs_to :coach
  belongs_to :team
  belongs_to :gameschedule
  
  index(  { team: 1 }, { unique: false } )
  index( { gameschedule: 1 } , { unique: false } )
  index( { owner: 1 } , { unique: false } )
  index(  { coach: 1 }, { unique: false } )
  index( { athlete: 1 } , { unique: false } )
  
  validates_presence_of :title
  
  search_in :title, :news
  
end
