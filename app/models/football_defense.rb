class FootballDefense
  include Mongoid::Document
  include Mongoid::Timestamps

  include SendAlert

  after_save :send_alerts
  
  field :tackles, type: Integer, default: 0
  field :assists, type: Integer, default: 0
  field :sacks, type: Integer, default: 0
  field :pass_defended, type: Integer, default: 0
  field :interceptions, type: Integer, default: 0
  field :int_yards, type: Integer, default: 0
  field :int_long, type: Integer, default: 0
  field :int_td, type: Integer, default: 0
  field :fumbles_recovered, type: Integer, default: 0
  
  embedded_in :football_stat

  validates_numericality_of :tackles
  validates_numericality_of :assists
  validates_numericality_of :sacks
  validates_numericality_of :pass_defended
  validates_numericality_of :interceptions, allow_nil: true
  validates_numericality_of :int_yards, allow_nil: true
  validates_numericality_of :int_long, allow_nil: true
  validates_numericality_of :int_td, allow_nil: true
  validates_numericality_of :fumbles_recovered, allow_nil: true

   private

    def send_alerts
      send_stat_alerts(self.football_stat.athlete.sport, self.football_stat.athlete, self.football_stat.gameschedule, "Defense Statistics Updated")
    end

end
