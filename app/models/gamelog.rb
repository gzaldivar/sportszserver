class Gamelog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :logentry, type: String
  field :period, type: String
  field :time, type: String
  field :score, type: String

  field :inning, type: Integer, default:0

  belongs_to :gameschedule

  # football stats
  
  belongs_to :football_defense
  belongs_to :football_passing
  belongs_to :football_rushing
  belongs_to :football_receiving
  belongs_to :football_kicking
  belongs_to :football_returner

  validates_presence_of :logentry
  validates_numericality_of :inning, greater_than_or_equal_to: 0

end
