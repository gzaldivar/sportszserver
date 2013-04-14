class Blog
  include Mongoid::Document  
  include Mongoid::Timestamps
  include Mongoid::Search
  
  field :title, type: String
  field :entry, type: String
  field :athlete, type: String
  field :game, type: String
  field :team, type: String
  field :coach, type: String
  field :external_url, type: String
  field :blogger, type: String

  belongs_to :sport

  validates_presence_of :title
  validates_presence_of :entry, :blogger

end
