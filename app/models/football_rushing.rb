class FootballRushing
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :comp_average

  field :attempts, type: Integer, default: 0
  field :yards, type: Integer, default: 0
  field :average, type: Float, default: Float(0)
  field :longest, type: Integer, default: 0
  field :td, type: Integer, default:0
  field :fumbles, type: Integer, default: 0
  field :fumbles_lost, type: Integer, default: 0
  field :twopointconv, type: Integer, default: 0
  field :firstdowns, type: Integer, default: 0
  
  belongs_to :athlete
  belongs_to :gameschedule
  has_many :alerts, dependent: :destroy
  has_many :gamelogs, dependent: :destroy
  
  validates_numericality_of :attempts, greater_than_or_equal_to: 0
  validates_numericality_of :yards
  validates_numericality_of :longest, greater_than_or_equal_to: 0
  validates_numericality_of :td, greater_than_or_equal_to: 0
  validates_numericality_of :fumbles, greater_than_or_equal_to: 0
  validates_numericality_of :fumbles_lost, greater_than_or_equal_to: 0
  validates_numericality_of :twopointconv, greater_than_or_equal_to: 0
  validates_numericality_of :firstdowns, greater_than_or_equal_to: 0
  
  def comp_average
    if self.attempts > 0 and self.yards > 0 
      self.average = Float(self.yards) / Float(self.attempts)
    else
      self.average = 0.0
    end
  end

end
