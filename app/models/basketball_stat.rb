class BasketballStat
  include Mongoid::Document
  include Mongoid::Timestamps

  field :twoattempt, type: Integer, default: 0
  field :twomade, type: Integer, default: 0
  field :threeattempt, type: Integer, default: 0
  field :threemade, type: Integer, default: 0
  field :ftmade, type: Integer, default: 0
  field :ftattempt, type: Integer, default: 0
  field :fouls, type: Integer, default: 0
  field :assists, type: Integer, default: 0
  field :steals, type: Integer, default: 0
  field :blocks, type: Integer, default: 0
  field :offrebound, type: Integer, default: 0
  field :defrebound, type: Integer, default: 0

  belongs_to :athlete
  belongs_to :gameschedule
  belongs_to :alerts

  index({ gameschedule: 1 }, { unique: true })

  validates_numericality_of :twoattempt, greater_than_or_equal_to: 0
  validates_numericality_of :twomade, greater_than_or_equal_to: 0
  validates_numericality_of :threeattempt, greater_than_or_equal_to: 0
  validates_numericality_of :threemade, greater_than_or_equal_to: 0
  validates_numericality_of :ftmade, greater_than_or_equal_to: 0
  validates_numericality_of :ftattempt, greater_than_or_equal_to: 0
  validates_numericality_of :steals, greater_than_or_equal_to: 0
  validates_numericality_of :fouls, greater_than_or_equal_to: 0
  validates_numericality_of :assists, greater_than_or_equal_to: 0
  validates_numericality_of :blocks, greater_than_or_equal_to: 0
  validates_numericality_of :offrebound, greater_than_or_equal_to: 0
  validates_numericality_of :defrebound, greater_than_or_equal_to: 0

end
