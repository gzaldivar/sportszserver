class FootballRushing
  include Mongoid::Document
  include Mongoid::Timestamps

  include SendAlert

  before_save :comp_average
  after_save :send_alerts

  field :attempts, type: Integer
  field :yards, type: Integer
  field :average, type: Float
  field :longest, type: Integer
  field :td, type: Integer
  field :fumbles, type: Integer
  field :fumbles_lost, type: Integer
  
  embedded_in :football_stat
  
  validates_numericality_of :attempts, greater_than: 0, presence: true
  validates_numericality_of :yards, presence: true
  validates_numericality_of :longest
  validates_numericality_of :td
  validates_numericality_of :fumbles
  validates_numericality_of :fumbles_lost

  def comp_average
    if self.attempts > 0 and self.yards > 0
      self.average = Float(self.yards) / Float(self.attempts)
    end
  end

  private

    def send_alerts
      send_stat_alerts(self.football_stat.athlete, self.football_stat.gameschedule, "Rushing Statistics Updated")
    end

end
