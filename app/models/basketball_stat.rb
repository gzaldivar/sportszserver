class BasketballStat
  include Mongoid::Document
  include Mongoid::Timestamps

  after_save :send_alerts

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
  field :turnovers, type: Integer, default: 0

  belongs_to :athlete
  belongs_to :gameschedule
  has_many :alerts, dependent: :destroy

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
  validates_numericality_of :turnovers, greater_than_or_equal_to: 0

  def twopct
    if twomade > 0
      Float(twomade)/Float(twoattempt)
    else
      0.0
    end
  end

  def threepct
    if threemade > 0
      Float(threemade)/Float(threeattempt)
    else
      0.0
    end
  end

  def ftpct
    if ftmade > 0
      Float(ftmade)/Float(ftattempt)
    else
      0.0
    end
  end

  def totalpoints
    (self.twomade * 2) + (self.threemade * 3) + self.ftmade
  end

  private

    def send_alerts
         player = Athlete.find(self.athlete_id)
         player.fans.each do |user|
            alert = athlete.alerts.create!(sport: player.sport, user: user, athlete: player.id, message: "Stat alert for " + 
                                          Gameschedule.find(gameschedule).game_name, basketball_stat: self.id)
        end   
    end

end
