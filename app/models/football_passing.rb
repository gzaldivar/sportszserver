class FootballPassing
  include Mongoid::Document
  include Mongoid::Timestamps

  include SendAlert

  before_save :comp_percent
  after_save :send_alerts

  field :attempts, type: Integer
  field :completions, type: Integer, default: 0
  field :yards, type: Integer
  field :td, type: Integer, default: 0
  field :interceptions, type: Integer, default: 0
  field :sacks, type: Integer, default: 0
  field :yards_lost, type: Integer, default: 0
  field :comp_percentage, type: Float
  
  embedded_in :football_stat
   
  validates_numericality_of :attempts, greater_than: 0, presence: true
  validates_numericality_of :completions, greater_than_or_equal_to: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :td, greater_than_or_equal_to: 0
  validates_numericality_of :interceptions, greater_than_or_equal_to: 0
  validates_numericality_of :sacks, greater_than_or_equal_to: 0
  validates_numericality_of :yards_lost, greater_than_or_equal_to: 0

  def comp_percent
    if !self.completions.nil? and !self.attempts.nil?
      self.comp_percentage = Float(self.completions) / Float(self.attempts)
    else
      self.comp_percentage = 0.0
    end
  end

 private

    def send_alerts
      send_stat_alerts(self.football_stat.athlete.sport, self.football_stat.athlete, self.football_stat.gameschedule, "Passing Statistics Updated")
    end

end
