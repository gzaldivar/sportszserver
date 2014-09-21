module LacrossesHelper

    include LacrosseStatistics

    def lacrosse_home_team
        "Home"
    end

    def lacrosse_visitor_team
        "Visitor"
    end

	def lacrosse_positions
	    [
	      ['Attacker', 'A'],
	      ['Midfielder', 'M'],
	      ['Defender', 'D'],
	      ['Goalie', 'G']
	    ]
    end

    def lacrosse_score_codes
    	[
    		['Broken clear resulted in goal', 'B'],
    		['Cutter scored after receiving feed', 'C'],
    		['Dodging goal', 'D'],
    		['Fast break goal', 'F'],
    		['Outside shot scored', 'O'],
    		['Extra man play scored', 'X']
    	]
    end

    def lacrosse_shots
        [
            ['Goal', 'G'],
            ['Save', 'S'],
            ['Pipe', 'P'],
            ['Wide', 'W']
        ]
    end

    def lacrosse_periods
        [
            ['1', '1'],
            ['2', '2'],
            ['3', '3'],
            ['4', '4'],
            ['OT', '5']
        ]
    end

    def lacrosse_display_period(period)
        if period == 5
            'OT'
        else
            period.to_s
        end
    end

    def lacrosse_shot_goal
        lacrosse_shots.each do |shot|
            if shot[0] == "Goal"
                return shot[1]
            end
        end
    end

    def lacrosse_player_assists(player, game)
        lacrosstat = game.lacross_game.lacrosstats.find_by(athlete_id: player.id)
        assist = 0 

        game.lacross_game.lacrosstats.each do |l|
            if l.lacross_scorings.find_by(assist: player.id)
                assist += 1
            end
        end

        return assist
    end
    
    def lacrosse_personal_fouls
        ['Slashing', 'Tripping', 'Cross Checking', 'Unsportsmanlike Conduct', 'Unnecessary Roughness', 'Illegal Crosse', 'Illegal Body Checking',
         'Illegal Gloves']
    end

    def lacrosse_technical_fouls
        ['Holding', 'Interference', 'Off Sides', 'Pushing', 'Screening', 'Stalling', 'Warding Off']
    end

    def lacrosse_fouls
        lacrosse_personal_fouls + lacrosse_technical_fouls
    end

    def lacrosse_shotlist(stats, period, home)
        shots = ''

        if home == "Home"
            number = Athlete.find(stats.lacross_game.athlete_id)
        else
            number = Athlete.find(stats.lacross_game.visitor_roster)
        end

        stats.each do |s|
            if s.period
                shots = shots + number.to_s
            end
        end

        return shots
    end

    def lacrosse_face_off(faceoffwon, faceofflost)
        puts 'faceoffwon =' + faceoffwon.to_s
        puts 'faceofflost = ' + faceofflost.to_s
        if faceoffwon == 0 and faceofflost == 0
            nil
        else
            faceoff = faceoffwon.to_s + '-' + faceofflost.to_s
        end
    end

    def getlacrosse_home_steals(game)
        lacrossehomesteals(game)
    end

    def getlacrosse_visitor_steals(game)
        lacrossevisitorsteals(game)
    end

    def getlacrosse_home_turnovers(game)
        lacrossehometurnovers(game)
    end

    def getlacrosse_visitor_turnovers(game)
        lacrossevisitorturnovers(game)
    end

    def lacrosse_extraman_scores_by_period(game, period, home)
        scores = 0

        if home == lacrosse_home_team
            if game.lacross_game
                game.lacross_game.lacrosstats.each do |l|
                    scores = l.lacross_scorings.where(period: period, scorecode: 'X' ).count
                end
            end
        else
            if game.lacross_game.visiting_team
                game.lacross_game.visiting_team.visitor_rosters.each do |v|
                    if v.lacrosstat
                        scores = v.lacrosstat.lacross_scorings.where(period: period, scorecode: 'X' ).count
                    end
                end
            end
        end

        return scores
    end

    def get_lacrosse_home_score(game)
        lacrossehomescore(game).inject{ |sum,x| sum + x }
    end

    def get_lacrosse_home_score_by_period(game)
        lacrossehomescore(game)
    end

    def get_lacrosse_visitor_score(game)
#        lacrossevisitorscore(game).inject{ |sum, x| sum + x }
        game.lacross_game.visitor_score_period1 + game.lacross_game.visitor_score_period2 + game.lacross_game.visitor_score_period3 +
        game.lacross_game.visitor_score_period4 + game.lacross_game.visitor_score_periodOT1
    end

    def get_lacrosse_visitor_score_by_period(game)
         lacrossevisitorscore(game)
    end

    def lacrosse_score_logs(game)
        scores = []

        game.lacross_game.lacrosstats.each do |l|
            l.lacross_scorings.each do |score|
                scores << score
            end
        end

        return scores
    end

end
