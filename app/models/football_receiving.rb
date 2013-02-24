class FootballReceiving
  include Mongoid::Document
  include Mongoid::Timestamps

  field :game, type: String
  field :receptions, type: Integer
  field :yards, type: Integer
  field :long, type: Integer
  field :td, type: Integer
  field :fumbles, type: Integer
  field :lost, type: Integer
  
  belongs_to :athlete, index: true
  
  index( { game: 1 }, { unique: false } )
  
  validates_presence_of :game
  validates_numericality_of :receptions, greater_than: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :long, presence: true
  validates_numericality_of :td
  validates_numericality_of :fumbles
  validates_numericality_of :lost
end
