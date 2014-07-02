module SoccersHelper

  def is_soccer_goalie?(positions)
    if positions.include? "GK"
      return true
    else
      return false
    end
  end

  def hasSoccerPlayerStats?(stats)
  	player = false
    
  	if stats.kind_of?(Array)
  		stats.each do |s|
  			if s.goals > 0 or s.shotstaken > 0 or s.assists > 0 or s.steals > 0
  				player = true
  				break
  			end
  		end
  	elsif stats.goals > 0 or stats.shotstaken > 0 or stats.assists > 0 or stats.steals > 0
  		player = true
  	end
    
    return player
  end

  def soccer_yellowcard
    [
      ['Unsporting Behavior', 'UB'],
      ['Dissent', 'DT'],
      ['Persistent Infringement', 'PI'],
      ['Delaying restart of play', 'DR'],
      ['Failure to Respect the Required Distance', 'FRD'],
      ['Entering or re-entering the field of play without referee permission', 'E'],
      ['Deliberately leaving the field of play without referee permission', 'L']
    ]
  end

  def soccer_redcard
    [
      ['Unsporting Behavior', 'UB'],
      ['Dissent by word or action', 'DT'],
      ['Delaying the restart of play', 'DR'],
      ['Serious foul play', 'SFP'],
      ['Violent conduct', 'VC'],
      ['Spitting at an opponent or any other person', 'S'],     
      ['Denying the opposing team a goal', 'DGH'],
      ['Denies an obvious goal-scoring opportunity', 'DGF'],
      ['Using offensive, insulting or abusive language and/or gestures', 'AL'],     
      ['Receiving a second caution in the same match', '2CT']
    ]
  end

  def soccer_periods
    [
      ['1', '1'],
      ['2', '2'],
      ['OT1', '3'],
      ['OT2', '4']
    ]
  end

  def soccergame_home_score(game)
    playerscores = game.soccer_game.soccer_stats
    score = 0

    playerscores.each do |s|
      score += s.soccer_scorings.count
    end

    return score
  end

  def soccergame_visitor_score(game)
    if game.soccer_game.visiting_team
      roster = game.soccer_game.visiting_team.visitor_rosters
      score = 0

      roster.each do |s|
        score += s.soccer_stat.soccer_scorings.count if s.soccer_stat
      end

      return score
    else
      0
    end
  end

  def soccergame_periodhomescore(game, period)
    scores = game.soccer_game.soccer_stats
    score = 0

    scores.each do |s|
      score += s.soccer_scorings.where(period: period).count
    end

    return score
  end

  def soccergame_periodvisitorscore(game, period)
    if game.soccer_game.visiting_team
      roster = game.soccer_game.visiting_team.visitor_rosters

      score = 0

      roster.each do |s|
        score += s.soccer_stat.soccer_scorings.where(period: period).count if s.soccer_stat
      end

      return score
    else
      0
    end
  end

  def soccergame_player_shots(game, player)
    shots = 0

    stat = game.soccer_game.soccer_stats.find_by(athlete_id: player.id)

    if !stat.nil?
      stat.soccer_playerstats.each do |s|
        shots += s.shots
      end
    end

    return shots
  end

  def soccergame_visiting_player_shots(game, player)
    shots = 0

    player.soccer_stats.find_by(soccer_game_id: game.soccer_game).soccer_playerstats.each do |stat|
      shots += stat.shots
    end
    
    return shots
  end

  def soccergame_player_goals(game, player)
    goals = 0

    stat = game.soccer_game.soccer_stats.find_by(athlete_id: player.id)

    if stat
      goals = stat.soccer_scorings.count
    end

    return goals
  end

  def soccergame_player_assists(game, player)
    assists = 0

    game.soccer_game.soccer_stats.each do |stat|
      assists = stat.soccer_scorings.where(assist: player.id).count
    end

    return assists
  end

  def soccergame_homeshots(game)
    stats = game.soccer_game.soccer_stats
    shots = 0

    stats.each do |s|
      s.soccer_playerstats.each do |astat|
        shots += astat.shots
      end
    end

    return shots
  end

  def soccergame_visitorshots(game)
    if game.soccer_game.visiting_team
      roster = game.soccer_game.visiting_team.visitor_rosters

      shots = 0

      roster.each do |s|
        stats = s.soccer_stat.soccer_playerstats.where(period: period) if s.soccer_stat

        if stats
          stats.each do |astat|
            shots += astat.shots
          end
        end
      end

      return shots
    else
      0
    end
  end

  def soccergame_homecornerkicks(game)
    stats = game.soccer_game.soccer_stats
    shots = 0

    stats.each do |s|
      s.soccer_playerstats.each do |astat|
        shots += astat.cornerkick
      end
    end

    return shots
  end

  def soccergame_visitorcornerkicks(game)
    if game.soccer_game.visiting_team
      roster = game.soccer_game.visiting_team.visitor_rosters

      shots = 0

      roster.each do |s|
        stats = s.soccer_stat.soccer_playerstats.where(period: period) if s.soccer_stat

        if stats
          stats.each do |astat|
            shots += astat.cornerkick
          end
        end
      end

      return shots
    else
      0
    end
  end

  def soccergame_homesaves(game)
    stats = game.soccer_game.soccer_stats
    shots = 0

    stats.each do |s|
      s.soccer_goalstats.each do |astat|
        shots += astat.saves
      end
    end

    return shots
  end

  def soccergame_visitorsaves(game)
    if game.soccer_game.visiting_team
      roster = game.soccer_game.visiting_team.visitor_rosters

      shots = 0

      roster.each do |s|
        stats = s.soccer_stat.soccer_goalstats.where(period: period) if s.soccer_stat

        if stats
          stats.each do |astat|
            shots += astat.saves
          end
        end
      end

      return shots
    else
      0
    end
  end

end
