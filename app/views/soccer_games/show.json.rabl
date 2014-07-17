object @soccer_game
node(:soccer_game_id) { |s| s.id.to_s }
node(:gameschedule_id) { |g| g.gameschedule.id.to_s }

node :visiting_team_id, :if => lambda { |v| v.visiting_team } do |v|
	v.visiting_team.id.to_s
end

node(:soccergame_home_score) { |sg| sg.score(sport_home_team) }
# node(:soccergame_home_score_period1) { |sg| sg.periodscore(sport_home_team, 1) }
node(:soccergame_home_score_period2) { |sg| sg.periodscore(sport_home_team, 2) }
node(:soccergame_home_score_periodOT1) { |sg| sg.periodscore(sport_home_team, 3) }
node(:soccergame_home_score_periodOT2) { |sg| sg.periodscore(sport_home_team, 4) }
node(:soccergame_visitor_score_period1) { |sg| sg.periodscore(sport_visitor_team, 1) }
node(:soccergame_visitor_score_period2) { |sg| sg.periodscore(sport_visitor_team, 2) }
node(:soccergame_visitor_score_periodOT1) { |sg| sg.periodscore(sport_visitor_team, 3) }
node(:soccergame_visitor_score_periodOT2) { |sg| sg.periodscore(sport_visitor_team, 4) }

child :soccer_subs, :object_root => false do
	node(:soccer_sub_id) { |s| s.id.to_s }
	node(:soccer_game_id) { |s| s.soccer_game.id.to_s }
	attributes :inplayer, :outplayer, :gametime, :home
end

node(:soccer_home_shots) { |sg| sg.shots(sport_home_team) }
node(:soccer_visitor_shots) { |sg| sg.shots(sport_visitor_team) }
node(:soccergame_homecornerkicks) { |sg| sg.cornerkicks(sport_home_team) }
node(:soccergame_visitorcornerkicks) { |sg| sg.cornerkicks(sport_visitor_team) }
node(:soccergame_homesaves) { |sg| sg.saves(sport_home_team) }
node(:soccergame_visitorsaves) { |sg| sg.saves(sport_visitor_team) }

attributes :socceroppsog, :socceroppck, :socceroppsaves, :socceroppfouls, :homefouls, :visitorfouls, :homeoffsides, :visitoroffsides, 
			:homeplayers, :visitorplayers
