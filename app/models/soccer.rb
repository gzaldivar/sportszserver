class Soccer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :goals, type: Integer, default: 0
  field :shotstaken, type: Integer, default: 0
  field :assists, type: Integer, default: 0
  field :steals, type: Integer, default: 0
  field :cornerkick, type: Integer, default: 0

  field :goalsagainst, type: Integer, default: 0
  field :goalssaved, type: Integer, default: 0
  field :shutouts, type: Integer, default: 0
  field :minutesplayed, type: Integer, default: 0

  belongs_to :athlete
  belongs_to :gameschedule
  has_many :alerts, dependent: :destroy
  has_many :gamelogs, dependent: :destroy

  index({ gameschedule: 1 }, { unique: true })

  validates_numericality_of :goals, greater_than_or_equal_to: 0
  validates_numericality_of :shotstaken, greater_than_or_equal_to: 0
  validates_numericality_of :assists, greater_than_or_equal_to: 0
  validates_numericality_of :steals, greater_than_or_equal_to: 0
  validates_numericality_of :cornerkick, greater_than_or_equal_to: 0

  validates_numericality_of :goalsagainst, greater_than_or_equal_to: 0
  validates_numericality_of :goalssaved, greater_than_or_equal_to: 0
  validates_numericality_of :shutouts, greater_than_or_equal_to: 0
  validates_numericality_of :minutesplayed, greater_than_or_equal_to: 0

end
