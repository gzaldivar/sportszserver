class FbpassingTotal
  include Mongoid::Document
  include Mongoid::Timestamps

  field :attempts, type: Integer
  field :completions, type: Integer
  field :percentage, type: Float
  field :yards, type: Integer
  field :td, type: Integer
  field :interceptions, type: Integer
  field :sacks, type: Integer
  field :yards_lost, type: Integer
  
  belongs_to :team, index: true
  
  validates_numericality_of :attempts, greater_than: 0, presence: true
  validates_numericality_of :completions, greater_than_or_equal_to: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :percentage, presence: true
  validates_numericality_of :yards_lost
end
