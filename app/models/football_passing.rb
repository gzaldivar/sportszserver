class FootballPassing
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :comp_percent

  field :attempts, type: Integer, default: 0
  field :completions, type: Integer, default: 0
  field :yards, type: Integer, default: 0
  field :td, type: Integer, default: 0
  field :interceptions, type: Integer, default: 0
  field :sacks, type: Integer, default: 0
  field :yards_lost, type: Integer, default: 0
  field :comp_percentage, type: Float, default: Float(0)
  field :twopointconv, type: Integer, default: 0
  field :firstdowns, type: Integer, default: 0
    
#  embedded_in :football_stat
  belongs_to :athlete
  belongs_to :gameschedule
  has_many :alerts, dependent: :destroy
   
  validates_numericality_of :attempts, greater_than_or_equal_to: 0
  validates_numericality_of :completions, greater_than_or_equal_to: 0
  validates_numericality_of :yards, greater_than_or_equal_to: 0
  validates_numericality_of :td, greater_than_or_equal_to: 0
  validates_numericality_of :interceptions, greater_than_or_equal_to: 0
  validates_numericality_of :sacks, greater_than_or_equal_to: 0
  validates_numericality_of :yards_lost, greater_than_or_equal_to: 0
  validates_numericality_of :twopointconv, greater_than_or_equal_to: 0
  validates_numericality_of :firstdowns, greater_than_or_equal_to: 0

  def comp_percent
    if !self.completions.nil? and !self.attempts.nil? and self.completions > 0 and self.attempts > 0
      self.comp_percentage = Float(self.completions) / Float(self.attempts)
    else
      self.comp_percentage = Float(0)
    end
  end

end
