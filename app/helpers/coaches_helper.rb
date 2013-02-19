module CoachesHelper
  
  def get_coaches(sport)
    coaches = []
    Coach.where("sport='#{sport.id}'").each_with_index do |a, cnt|
      coaches[cnt] = a
    end
    return coaches
  end
  
  def get_team_coaches(sport, team)
    coaches = []
    Coach.where("sport='#{@sport.id}' and team='#{team}'").each_with_index do |a, cnt|
      coaches[cnt] = a
    end
    return coaches
  end
  
end
