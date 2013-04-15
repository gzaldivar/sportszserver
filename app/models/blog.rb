class Blog
  include Mongoid::Document  
  include Mongoid::Timestamps
  include Mongoid::Search
  
  field :title, type: String
  field :entry, type: String
  field :external_url, type: String
  field :blogger, type: String

  belongs_to :sport
  belongs_to :team
  belongs_to :athlete
  belongs_to :coach
  belongs_to :gameschedule

  validates_presence_of :title
  validates_presence_of :entry, :blogger

end
