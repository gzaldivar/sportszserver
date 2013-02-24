class FootballRushing
  include Mongoid::Document
  include Mongoid::Timestamps

  field :game, type: String
  field :attempts, type: Integer
  field :yards, type: Integer
  field :longest, type: Integer
  field :td, type: Integer
  field :fumbles, type: Integer
  field :fumbles_lost, type: Integer
  
  belongs_to :athlete, index: true
  
  index( { game: 1 }, { unique: false } )
  
  validates_presence_of :game
  validates_numericality_of :attempts, greater_than: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :longest
  validates_numericality_of :td
  validates_numericality_of :fumbles
  validates_numericality_of :fumbles_lost
end
