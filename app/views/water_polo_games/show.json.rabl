object @water_polo_game
node(:water_polo_game_id) { |s| s.id.to_s }
node(:gameschedule_id) { |g| g.gameschedule.id.to_s }

node :visiting_team_id, :if => lambda { |v| v.visiting_team } do |v|
	v.visiting_team.id.to_s
end

node(:waterpolo_game_home_score) { |sg| sg.score(sport_home_team) }
node(:waterpolo_game_home_score_period1) { |sg| sg.periodscore(sport_home_team, 1) }
node(:waterpolo_game_home_score_period2) { |sg| sg.periodscore(sport_home_team, 2) }
node(:waterpolo_game_home_score_periodOT1) { |sg| sg.periodscore(sport_home_team, 3) }
node(:waterpolo_game_home_score_periodOT2) { |sg| sg.periodscore(sport_home_team, 4) }
node(:waterpolo_game_visitor_score) { |sg| sg.score(sport_visitor_team) }
node(:waterpolo_game_visitor_score_period1) { |sg| sg.periodscore(sport_visitor_team, 1) }
node(:waterpolo_game_visitor_score_period2) { |sg| sg.periodscore(sport_visitor_team, 2) }
node(:waterpolo_game_visitor_score_periodOT1) { |sg| sg.periodscore(sport_visitor_team, 3) }
node(:waterpolo_game_visitor_score_periodOT2) { |sg| sg.periodscore(sport_visitor_team, 4) }

node(:waterpolo_home_shots) { |sg| sg.shots(sport_home_team) }
node(:waterpolo_visitor_shots) { |sg| sg.shots(sport_visitor_team) }
node(:waterpolo_game_homesaves) { |sg| sg.saves(sport_home_team) }
node(:waterpolo_game_visitorsaves) { |sg| sg.saves(sport_visitor_team) }
node(:waterpolo_home_steals) { |sg| sg.steals(sport_home_team) }
node(:waterpolo_visitor_steals) { |sg| sg.steals(sport_visitor_team) }
node(:waterpolo_game_home_fouls) { |sg| sg.fouls(sport_home_team) }
node(:waterpolo_game_visitor_fouls) { |sg| sg.fouls(sport_visitor_team) }

attributes :waterpolo_oppsog, :waterpolo_oppsaves, :waterpolo_oppfouls, :waterpolo_oppassists, :home_time_outs_left, :visitor_time_outs_left, :exclusions
