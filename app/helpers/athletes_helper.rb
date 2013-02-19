module AthletesHelper
  
  def get_athlete_team(sport, team)
    sport.teams.find(team).team_name
  end

end
