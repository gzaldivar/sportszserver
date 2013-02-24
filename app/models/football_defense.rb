class FootballDefense
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :game, type: String
  field :tackles, type: Integer
  field :assists, type: Integer
  field :sacks, type: Integer
  field :pass_defended, type: Integer
  field :interceptions, type: Integer
  field :int_yards, type: Integer
  field :int_long, type: Integer
  field :int_td, type: Integer
  field :fumbles_recovered, type: Integer
  
  belongs_to :athlete, index: true
  
  index( { game: 1 }, { unique: false } )
  
  validates_presence_of :game
  validates_numericality_of :tackles
  validates_numericality_of :assists
  validates_numericality_of :sacks
  validates_numericality_of :pass_defended
  validates_numericality_of :interceptions
  validates_numericality_of :int_yards
  validates_numericality_of :int_long
  validates_numericality_of :int_td
  validates_numericality_of :fumbles_recovered
end
