module AthletesHelper
  
  def get_athlete_team(sport, team)
    sport.teams.find(team).team_name
  end

  def athlete_stats?(athlete)
  	if !athlete.football_passings.nil? or !athlete.football_rushings.nil?
  		return true
  	else
  		return false
  	end
  end

  def height_feet
    [
      ["3", "3"],
      ["4", "4"],
      ["5", "5"],
      ["6", "6"],
      ["7", "7"],
      ["8", "8"]
    ]
  end

  def height_inches
    [
      ["0", "0"],
      ["1", "1"],
      ["2", "2"],
      ["3", "3"],
      ["4", "4"],
      ["5", "5"],
      ["6", "6"],
      ["7", "7"],
      ["8", "8"],
      ["9", "9"],
      ["10", "10"],
      ["11", "11"],
      ["12", "12"]
    ]
  end

  def isQB?(athlete)
    aQB = false
    athlete.position.split('/').each do |pos|
      if pos == "QB"
        aQB = true
        break
      end
    end
    return aQB
  end

  def isRB?(athlete)
    aRB = false
    athlete.position.split('/').each do |pos|
      if pos == "RB" or pos == "TB" or pos == "FB"
        aRB = true
        break
      end
    end
    return aRB
  end

  def isFBRec?(athlete)
    aRec = false
    athlete.position.split('/').each do |pos|
      if pos == "WR" or pos == "TE"
        aRec = true
        break
      end
    end
    return aRec
  end
  
  def isFBDEF?(athlete)
    aDef = false
    athlete.position.split('/').each do |pos|
      if pos == 'DL' or pos == 'NG' or pos == 'DT' or pos == 'DE' or pos == 'LB' or pos == 'DB' or pos == 'CB' or pos == 'S' or pos == 'SS'
        aDef = true
        break
      end
    end
    return aDef
  end
  
  def FBPlaceKicker?(athlete)
    aPK = false
    athlete.position.split('/').each do |pos|
      if pos == 'PK' or pos == 'PKP'
        aPK = true
        break
      end
    end
    return aPK
  end

  def FBKicker?(athlete)
    aKicker = false
    athlete.position.split('/').each do |pos|
      if pos == 'K' or pos == 'KP'
        aKicker = true
        break
      end
    end
    return aKicker
  end

  def FBPunter?(athlete)
    aPunter = false
    athlete.position.split('/').each do |pos|
      if pos == 'P' or pos == 'KP' or pos == 'PKP'
        aPunter = true
        break
      end
    end
    return aPunter
  end

  def FBPuntReturner?(athlete)
    puntreturner = false
    athlete.position.split('/').each do |pos|
      if pos == 'RET'
        puntreturner = true
        break
      end
    end
    return puntreturner
  end

  def FBKickReturner?(athlete)
    kickreturner = false
    athlete.position.split('/').each do |pos|
      if pos == 'RET'
        kickreturner = true
        break
      end
    end
    return kickreturner
  end

  def getimage(player, size)
    if player.pic?
      player.pic.url(size)
    else
      'photo_not_available.png'
    end
  end
end
