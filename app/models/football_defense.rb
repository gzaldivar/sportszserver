class FootballDefense
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :tackles, type: Integer, default: 0
  field :assists, type: Integer, default: 0
  field :sacks, type: Integer, default: 0
  field :pass_defended, type: Integer, default: 0
  field :interceptions, type: Integer, default: 0
  field :int_yards, type: Integer, default: 0
  field :int_long, type: Integer, default: 0
  field :int_td, type: Integer, default: 0
  field :fumbles_recovered, type: Integer, default: 0
  
  embedded_in :football_stat

  validates_numericality_of :tackles, greater_than_or_equal_to: 0
  validates_numericality_of :assists, greater_than_or_equal_to: 0
  validates_numericality_of :sacks, greater_than_or_equal_to: 0
  validates_numericality_of :pass_defended, greater_than_or_equal_to: 0
  validates_numericality_of :interceptions, greater_than_or_equal_to: 0
  validates_numericality_of :int_yards, greater_than_or_equal_to: 0
  validates_numericality_of :int_long, greater_than_or_equal_to: 0
  validates_numericality_of :int_td, greater_than_or_equal_to: 0
  validates_numericality_of :fumbles_recovered, greater_than_or_equal_to: 0

end
