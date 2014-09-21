class HockeyGame
	include Mongoid::Document
    include Mongoid::Timestamps

    include SportsHelper

    field :hockey_oppsog, type: Integer, default: 0
    field :hockey_oppassists, type: Integer, default: 0
    field :hockey_oppsaves, type: Integer, default: 0
    field :hockey_opppenalties, type: Integer, default: 0

#    field :penalties, type: Array

    field :home_time_outs_left, type: Integer, default: 3
    field :visitor_time_outs_left, type: Integer, default: 3

    field :visitor_score_period1, type: Integer, default: 0
    field :visitor_score_period2, type: Integer, default: 0
    field :visitor_score_period3, type: Integer, default: 0
    field :visitor_score_periodOT, type: Integer, default: 0

    field :home_penalty_one_number, type: Integer, default: 0
    field :home_penalty_one_minutes, type: Integer, default: 0
    field :home_penalty_one_seconds, type: Integer, default: 0
    field :home_penalty_two_number, type: Integer, default: 0
    field :home_penalty_two_minutes, type: Integer, default: 0
    field :home_penalty_two_seconds, type: Integer, default: 0

    field :visitor_penalty_one_number, type: Integer, default: 0
    field :visitor_penalty_one_minutes, type: Integer, default: 0
    field :visitor_penalty_one_seconds, type: Integer, default: 0
    field :visitor_penalty_two_number, type: Integer, default: 0
    field :visitor_penalty_two_minutes, type: Integer, default: 0
    field :visitor_penalty_two_seconds, type: Integer, default: 0

	embedded_in :gameschedule

	has_many :hockey_stats, dependent: :destroy
	has_one :visiting_team

    validates_numericality_of :hockey_oppsog, greater_than_or_equal_to: 0
    validates_numericality_of :hockey_oppassists, greater_than_or_equal_to: 0
    validates_numericality_of :hockey_oppsaves, greater_than_or_equal_to: 0
    validates_numericality_of :home_time_outs_left, greater_than_or_equal_to: 0
    validates_numericality_of :visitor_time_outs_left, greater_than_or_equal_to: 0

    def score(home)
        score = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            score += s.hockey_scorings.count
        end

        return score
    end

    def periodscore(home, period)
        score = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            score += s.hockey_scorings.where(period: period).count
        end

        return score
    end

    def shots(home)
        shots = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.hockey_playerstats.each do |astat|
                shots += astat.shots
            end
        end

        return shots
    end

    def penalties(home)
        penalties = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.hockey_playerstats.each do |astat|
                penalties += astat.penalties
            end
        end

        return penalties
    end

    def saves(home)
        saves = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.hockey_goalstats.each do |astat|
                saves += astat.saves
            end
        end

        return saves
    end

    def minutes_played(home)
        minutes_played = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.hockey_goalstats.each do |astat|
                minutes_played += astat.minutes_played
            end
        end

        return minutes_played
    end

    def goals_allowed(home)
        goals_allowed = 0

        hockey_stats.where(:visiting_roster_id.exists => home == sport_home_team ? false : true).each do |s|
            s.hockey_goalstats.each do |astat|
                goals_allowed += astat.goals_allowed
            end
        end

        return goals_allowed
    end
end