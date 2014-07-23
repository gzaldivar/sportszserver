class WaterPoloGame
	include Mongoid::Document
    include Mongoid::Timestamps

    include SportsHelper

    field :waterpolo_oppsog, type: Integer, default: 0
    field :waterpolo_oppassists, type: Integer, default: 0
    field :waterpolo_oppsaves, type: Integer, default: 0
    field :waterpolo_oppfouls, type: Integer, default: 0

    field :exclusions, type: Array

    field :home_time_outs_left, type: Integer, default: 3
    field :visitor_time_outs_left, type: Integer, default: 3

	embedded_in :gameschedule

	has_many :waterpolo_stats, dependent: :destroy
	has_one :visiting_team

    validates_numericality_of :waterpolo_oppsog, greater_than_or_equal_to: 0
    validates_numericality_of :waterpolo_assists, greater_than_or_equal_to: 0
    validates_numericality_of :waterpolo_oppsaves, greater_than_or_equal_to: 0
    validates_numericality_of :waterpolo_oppfouls, greater_than_or_equal_to: 0
    validates_numericality_of :home_time_outs_left, greater_than_or_equal_to: 0
    validates_numericality_of :visitor_time_outs_left, greater_than_or_equal_to: 0

    def score(home)
        score = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            score += s.waterpolo_scorings.count
        end

        return score
    end

    def periodscore(home, period)
        score = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            score += s.waterpolo_scorings.where(period: period).count
        end

        return score
    end

    def shots(home)
        shots = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.waterpolo_playerstats.each do |astat|
                shots += astat.shots
            end
        end

        return shots
    end

    def steals(home)
        steals = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.waterpolo_playerstats.each do |astat|
                steals += astat.steals
            end
        end

        return steals
    end

    def fouls(home)
        fouls = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.waterpolo_playerstats.each do |astat|
                fouls += astat.fouls
            end
        end

        return fouls
    end

    def saves(home)
        saves = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.waterpolo_goalstats.each do |astat|
                saves += astat.saves
            end
        end

        return saves
    end

    def minutes_played(home)
        minutes_played = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.waterpolo_goalstats.each do |astat|
                minutes_played += astat.minutes_played
            end
        end

        return minutes_played
    end

    def goals_allowed(home)
        goals_allowed = 0

        waterpolo_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.waterpolo_goalstats.each do |astat|
                goals_allowed += astat.goals_allowed
            end
        end

        return goals_allowed
    end
end