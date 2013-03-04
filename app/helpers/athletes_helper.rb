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

end
