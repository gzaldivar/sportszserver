class Gamelog
  include Mongoid::Document
  include Mongoid::Timestamps

  before_destroy :updatestats

  field :logentry, type: String
  field :period, type: String
  field :time, type: String
  field :score, type: String

  field :inning, type: Integer, default: 0

  field :player, type: String
  field :assist, type: String

  field :yards, type: Integer, default: 0
    
  belongs_to :gameschedule

  # football stats
  
  validates_presence_of :logentry
  validates_numericality_of :inning, greater_than_or_equal_to: 0

  def logentrytext
    theplayer = Athlete.find(player)
    if theplayer.sport.isFootball?
      if isPasser?
        self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.yards.to_s + " " + self.logentry + " " +
        Athlete.find(self.assist).logname + " - " + self.score
      elsif isReturner?
        self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.yards.to_s + " yard " + self.logentry + " - " + self.score
      else
        self.period + ": " + self.time + " - " +  theplayer.logname + " " + self.yards.to_s + " " + self.logentry + " - " + self.score
      end
    end
  end

  def isPasser?
    if footballPosition == "pass"
      return true
    else
      return nil
    end
  end

  def isRusher?
    if footballPosition == "run"
      return true
    else
      return nil
    end
  end

  def isReturner?
    if footballPosition == "return"
      return true
    else
      return nil
    end
  end

  def isReceiver?
    if footballPosition == "pass" and !self.assist.nil?
      return true
    else
      return nil
    end
  end

  def isDefense?
    if footballPosition == "interception" || footballPosition == "fumble"
      return true
    else
      return nil
    end
  end

  private

    def updatestats
      if Athlete.find(player).sport.isFootball?
        if isReceiver?
          stat = gameschedule.football_stats.find_by(athlete: self.player).football_passings
          rec = gameschedule.football_stats.find_by(athlete: self.assist).football_receivings
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
        elsif isRusher?
          stat = gameschedule.football_stats.find_by(athlete: self.player).football_rushings
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
        elsif isDefense?
          stat = gameschedule.football_stats.find_by(athlete: self.player).football_defenses
          stat.int_yards-= self.yards
          if footballPosition == "interception" and stat.interception > 0
            stat.interceptions -= 1
          elsif stat.fumbles_recovered > 0
            stat.fumbles_recovered -=1
          end
          if self.score = "TD" and stat.td > 0
            stat.td -= 1
          elsif stat.safety > 0
            stat.safety -= 1
          end
          stat.save!
        elsif isReturner?
          rettype = logentry.split(" ")
          stat = gameschedule.football_stats.find_by(athlete: self.player).football_returners
          if rettype[0] == "punt"
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
        end
        adjustgamescore
      end
    end

    def footballPosition
      position = self.logentry.split(" ")
      return position[1]
    end

    def adjustgamescore
      game = Gameschedule.find(gameschedule)
      if Athlete.find(player).sport.isFootball?
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
        end
      end
      game.save!
    end

end
