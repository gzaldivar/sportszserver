class FootballRushing
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :comp_average

  field :attempts, type: Integer
  field :yards, type: Integer
  field :average, type: Float
  field :longest, type: Integer, default: 0
  field :td, type: Integer, default:0
  field :fumbles, type: Integer, default: 0
  field :fumbles_lost, type: Integer, default: 0
  field :twopointconv, type: Integer, default: 0
  
  embedded_in :football_stat
  
  validates_numericality_of :attempts, greater_than_or_equal_to: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :longest, greater_than_or_equal_to: 0
  validates_numericality_of :td, greater_than_or_equal_to: 0
  validates_numericality_of :fumbles, greater_than_or_equal_to: 0
  validates_numericality_of :fumbles_lost, greater_than_or_equal_to: 0
  validates_numericality_of :twopointconv, greater_than_or_equal_to: 0
  
  def comp_average
    if self.attempts > 0 and self.yards > 0
      self.average = Float(self.yards) / Float(self.attempts)
    end
  end

end
