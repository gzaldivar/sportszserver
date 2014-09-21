object @hockey_game
node(:hockey_game_id) { |s| s.id.to_s }
node(:gameschedule_id) { |g| g.gameschedule.id.to_s }

node(:home_score) { |sg| sg.score(sport_home_team) }
node(:home_score_period1) { |sg| sg.periodscore(sport_home_team, 1) }
node(:home_score_period2) { |sg| sg.periodscore(sport_home_team, 2) }
node(:home_score_period3) { |sg| sg.periodscore(sport_home_team, 3) }
node(:home_score_periodOT) { |sg| sg.periodscore(sport_home_team, 4) }

node(:hockey_penalties) { hockey_penalties }

node(:visitor_score) { |sg| sg.visitor_score_period1 + sg.visitor_score_period2 + sg.visitor_score_period3 + sg.visitor_score_periodOT }

node(:home_shots) { |sg| sg.shots(sport_home_team) }
node(:home_saves) { |sg| sg.saves(sport_home_team) }
node(:home_goals_allowed) { |sg| sg.goals_allowed(sport_home_team) }

attributes :hockey_oppsog, :hockey_oppsaves, :hockey_opppenalties, :hockey_oppassists, :home_time_outs_left, :visitor_time_outs_left, 
		   :visitor_score_period1, :visitor_score_period2, :visitor_score_period3, :visitor_score_periodOT, :home_penalty_one_number, :home_penalty_one_minutes,
		   :home_penalty_one_seconds, :home_penalty_two_number, :home_penalty_two_minutes, :home_penalty_two_seconds, :visitor_penalty_one_number, 
		   :visitor_penalty_one_minutes, :visitor_penalty_one_seconds, :visitor_penalty_two_number, :visitor_penalty_two_minutes, :visitor_penalty_two_seconds
