class SoccerGame
	include Mongoid::Document
    include Mongoid::Timestamps

    include SportsHelper

    field :socceroppsog, type: Integer, default: 0
    field :socceroppck, type: Integer, default: 0
    field :socceroppsaves, type: Integer, default: 0
    field :socceroppfouls, type: Integer, default: 0

    field :homefouls, type: Integer, default: 0
    field :visitorfouls, type: Integer, default: 0
    field :homeoffsides, type: Integer, default: 0
    field :visitoroffsides, type: Integer, default: 0

    field :homeplayers, type: Array
    field :visitorplayers, type: Array

    field :visitor_score_period1, type: Integer, default: 0
    field :visitor_score_period2, type: Integer, default: 0
    field :visitor_score_periodOT1, type: Integer, default: 0
    field :visitor_score_periodOT2, type: Integer, default: 0

	embedded_in :gameschedule

	has_many :soccer_stats, dependent: :destroy
	has_one :visiting_team
    embeds_many :soccer_subs

    validates_numericality_of :socceroppfouls, greater_than_or_equal_to: 0
    validates_numericality_of :socceroppck, greater_than_or_equal_to: 0
    validates_numericality_of :socceroppsaves, greater_than_or_equal_to: 0
    validates_numericality_of :socceroppfouls, greater_than_or_equal_to: 0

    validates_numericality_of :homefouls, greater_than_or_equal_to: 0
    validates_numericality_of :visitorfouls, greater_than_or_equal_to: 0
    validates_numericality_of :homeoffsides, greater_than_or_equal_to: 0
    validates_numericality_of :visitoroffsides, greater_than_or_equal_to: 0

    def score(home)
        score = 0
        
        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            score += s.soccer_scorings.count
        end

        return score
    end

    def periodscore(home, period)
        score = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            score += s.soccer_scorings.where(period: period).count
        end

        return score
    end

    def shots(home)
        shots = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_playerstats.each do |astat|
                shots += astat.shots
            end
        end

        return shots
    end

    def cornerkicks(home)
        cornerkicks = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_playerstats.each do |astat|
                cornerkicks += astat.cornerkick
            end
        end

        return cornerkicks
    end

    def steals(home)
        steals = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_playerstats.each do |astat|
                steals += astat.steals
            end
        end

        return steals
    end

    def fouls(home)
        fouls = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_playerstats.each do |astat|
                fouls += astat.fouls
            end
        end

        return fouls
    end

    def saves(home)
        saves = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_goalstats.each do |astat|
                saves += astat.saves
            end
        end

        return saves
    end

    def minutes_played(home)
        minutes_played = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_goalstats.each do |astat|
                minutes_played += astat.minutes_played
            end
        end

        return minutes_played
    end

    def goals_allowed(home)
        goals_allowed = 0

        soccer_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.soccer_goalstats.each do |astat|
                goals_allowed += astat.goals_allowed
            end
        end

        return goals_allowed
    end
end