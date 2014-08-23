object @hockey_game
node(:hockey_game_id) { |s| s.id.to_s }
node(:gameschedule_id) { |g| g.gameschedule.id.to_s }

node(:hockey_game_home_score) { |sg| sg.score(sport_home_team) }
node(:hockey_game_home_score_period1) { |sg| sg.periodscore(sport_home_team, 1) }
node(:hockey_game_home_score_period2) { |sg| sg.periodscore(sport_home_team, 2) }
node(:hockey_game_home_score_period3) { |sg| sg.periodscore(sport_home_team, 3) }
node(:hockey_game_home_score_periodOT1) { |sg| sg.periodscore(sport_home_team, 4) }
node(:hockey_game_visitor_score) { |sg| sg.score(sport_visitor_team) }
node(:hockey_game_visitor_score_period1) { |sg| sg.periodscore(sport_visitor_team, 1) }
node(:hockey_game_visitor_score_period2) { |sg| sg.periodscore(sport_visitor_team, 2) }
node(:hockey_game_visitor_score_period3) { |sg| sg.periodscore(sport_visitor_team, 3) }
node(:hockey_game_visitor_score_periodOT2) { |sg| sg.periodscore(sport_visitor_team, 4) }

node(:hockey_home_shots) { |sg| sg.shots(sport_home_team) }
node(:hockey_visitor_shots) { |sg| sg.shots(sport_visitor_team) }
node(:hockey_game_homesaves) { |sg| sg.saves(sport_home_team) }
node(:hockey_game_visitorsaves) { |sg| sg.saves(sport_visitor_team) }
node(:hockey_game_home_fouls) { |sg| sg.fouls(sport_home_team) }
node(:hockey_game_visitor_fouls) { |sg| sg.fouls(sport_visitor_team) }

attributes :hockey_oppsog, :hockey_oppsaves, :hockey_opppenalties, :hockey_oppassists, :home_time_outs_left, :visitor_time_outs_left, :penalties
