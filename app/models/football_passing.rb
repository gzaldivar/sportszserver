class FootballPassing
  include Mongoid::Document
  include Mongoid::Timestamps

  field :game, type: String
  field :attempts, type: Integer
  field :completions, type: Integer
  field :yards, type: Integer
  field :td, type: Integer
  field :interceptions, type: Integer
  field :sacks, type: Integer
  field :yards_lost, type: Integer
  
  belongs_to :athlete, index: true
  
  index( { game: 1 }, { unique: false } )
  
  validates_numericality_of :attempts, greater_than: 0, presence: true
  validates_numericality_of :completions, greater_than_or_equal_to: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :yards_lost
end
