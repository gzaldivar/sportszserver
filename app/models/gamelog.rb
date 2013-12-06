class Gamelog
  include Mongoid::Document
  include Mongoid::Timestamps

  before_destroy :updatestats
  before_save :logentrytext

  field :logentry, type: String
  field :period, type: String
  field :time, type: String
  field :score, type: String

  field :inning, type: Integer, default: 0

  field :assist, type: String

  field :yards, type: Integer, default: 0
    
  belongs_to :gameschedule
  has_many :photos
  has_many :videoclips
  has_many :blogs

  belongs_to :football_passing
  belongs_to :football_rushing
  belongs_to :football_defense
  belongs_to :football_returner
  belongs_to :football_place_kicker

  # football stats
  
  validates_presence_of :logentry
  validates_numericality_of :inning, greater_than_or_equal_to: 0

  def logentrytext 
    if football_passing_id
      theplayer = Athlete.find(FootballPassing.find(football_passing_id).athlete_id)
      self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.yards.to_s + " yard pass to " +
      Athlete.find(self.assist).logname + " - " + self.score
    elsif football_returner_id
      theplayer = Athlete.find(FootballReturner.find(football_returner_id).athlete_id.to_s)
      self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.yards.to_s + " yard " + self.logentry + " - " + self.score
    elsif football_defense_id
      theplayer = Athlete.find(FootballDefense.find(football_defense_id).athlete_id.to_s)
      if self.score == "2P"
        self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.logentry + " - " + self.score
      else
        self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.yards.to_s + " " + self.logentry + " - " + self.score
      end        
    elsif football_place_kicker_id and self.score == "FG" or self.score == "XP"
      theplayer = Athlete.find(FootballPlaceKicker.find(football_place_kicker_id).athlete_id)
      self.period + ": " + self.time + " - " + theplayer.logname + " " + self.yards.to_s + " yard " + self.score
    elsif football_rushing_id
      theplayer = Athlete.find(FootballRushing.find(football_rushing_id).athlete_id.to_s)
      self.period + ": " + self.time + " - " + theplayer.logname + " " + self.score
    end
  end

  private

    def updatestats
      theplayer = nil

      if football_passing_id
        theplayer = Athlete.find(FootballPassing.find(football_passing_id).athlete_id)

        stat = FootballPassing.find(football_passing_id)
        rec = FootballReceiving.where(gameschedule_id: gameschedule_id, athlete_id: assist).first
        if stat.yards > 0
          stat.yards = stat.yards - self.yards
        end
        if rec.yards > 0
          rec.yards = rec.yards - self.yards
        end
        if rec.receptions > 0
          rec.receptions = rec.receptions - 1
        end
        if stat.completions > 0
          stat.completions = stat.completions - 1
        end
        if stat.attempts > 0
          stat.attempts = stat.attempts - 1
        end
        if self.score = "TD" 
          if stat.td > 0
            stat.td = stat.td - 1
          end
          if rec.td > 0
            rec.td = rec.td - 1
          end
        else
          if stat.twopointconv > 0
            stat.twopointconv = stat.twopointconv - 1
          end
          if rec.twopointconv > 0
            rec.twopointconv = rec.twopointconv - 1
          end
        end
        stat.save!
        rec.save!

      elsif football_rushing_id
        theplayer = Athlete.find(FootballRushing.find(football_rushing_id).athlete_id)

        stat = FootballRushing.find(football_rushing_id)
        if stat.yards > 0
          stat.yards -= self.yards
        end
        if stat.attempts > 0
          stat.attempts = stat.attempts - 1
        end
        if self.score = "TD" and stat.td > 0
          stat.td = stat.td - 1
        elsif stat.twopointconv > 0
          stat.twopointconv = stat.twopointconv - 1
        end
        stat.save!

      elsif football_defense_id
        theplayer = Athlete.find(FootballDefense.find(football_defense_id).athlete_id)
        stat = FootballDefense.find(football_defense_id)
        stat.int_yards-= self.yards
        if footballPosition == "interception" and stat.interception > 0
          stat.interceptions -= 1
        elsif stat.fumbles_recovered > 0
          stat.fumbles_recovered -=1
        end
        if self.score = "TD" and stat.int_td > 0
          stat.int_td -= 1
        elsif stat.safety > 0
          stat.safety -= 1
        end
        stat.save!#        elsif isReturner?

      elsif football_returner_id
        theplayer = Athlete.find(FootballReturner.find(football_returner_id).athlete_id)

        rettype = logentry.split(" ")
        stat = FootballReturner.find(football_returner_id)

        if rettype[0] == "punt"
          if stat.punt_returnlong == stat.punt_returnyards
            stat.punt_returnlong =0
          end
          if stat.punt_returnyards > 0
            stat.punt_returnyards -= self.yards
          end
          if stat.punt_return > 0
            stat.punt_return -= 1
          end
          if self.score = "TD" and stat.punt_returntd > 0
            stat.punt_returntd -= 1
          end
        else
          if stat.kolong == stat.koyards
            stat.kolong =0
          end
          if stat.koyards > 0
            stat.koyards -= self.yards
          end
          if stat.koreturns > 0
            stat.koreturns -= 1
          end
          if self.score = "TD" and stat.kotd > 0
            stat.kotd -= 1
          end
        end
        stat.save!

      elsif football_place_kicker_id
        theplayer = Athlete.find(FootballPlaceKicker.find(football_place_kicker_id).athlete_id)
        stat = FootballPlaceKicker.find(football_place_kicker_id)

        if self.score == "FG"
          stat.fgmade -= 1
          stat.fgattempts -=1
        elsif self.score == "XP"
          stat.xpmade -= 1
          stat.xpattempts -= 1
        end

        stat.save!
      end

      adjustgamescore
    end

    def adjustgamescore
      game = Gameschedule.find(gameschedule)

      if self.score == "TD"
        case self.period
        when "Q1"
          if game.homeq1 > 0
            game.homeq1-=6
          end
        when "Q2"
          if game.homeq2 > 0
            game.homeq2-=6
          end
        when "Q3"
          if game.homeq3 > 0
            game.homeq3-=6
          end
        when "Q4"
          if game.homeq4 > 0
            game.homeq4-=6
          end
        end
      elsif self.score == "2P"
        case self.period
        when "Q1"
          if game.homeq1 > 0
            game.homeq1-=2
          end
        when "Q2"
          if game.homeq2 > 0
            game.homeq2-=2
          end
        when "Q3"
          if game.homeq3 > 0
            game.homeq3-=2
          end
        when "Q4"
          if game.homeq4 > 0
            game.homeq4-=2
          end
        end
      elsif self.score == "FG"
        case self.period
        when "Q1"
          if game.homeq1 > 0
            game.homeq1 -= 3
          end
        when "Q2"
          if game.homeq2 > 0
            game.homeq2 -= 3
          end
        when "Q3"
          if game.homeq3 > 0
            game.homeq3 -= 3
          end
        when "Q4"
          if game.homeq4 > 0
            game.homeq4 -= 3
          end
        end
      elsif self.score == "XP"
        case self.period
        when "Q1"
          if game.homeq1 > 0
            game.homeq1 -= 1
          end
        when "Q2"
          if game.homeq2 > 0
            game.homeq2 -= 1
          end
        when "Q3"
          if game.homeq3 > 0
            game.homeq3 -= 1
          end
        when "Q4"
          if game.homeq4 > 0
            game.homeq4 -= 1
          end
        end
      end

      game.save!
    end

    def footballPosition
      position = self.logentry.split(" ")
      return position[1]
    end

end
