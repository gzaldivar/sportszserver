object @gameschedule
node(:id) { |o| o.id.to_s }
node(:team_id) { |t| t.team_id.to_s }
node :opponentpic, :if => lambda { |a| a.opponent_team_id? } do |a|
	if Sport.find(a.opponent_sport_id).teams.find(a.opponent_team_id).team_logo?
		Sport.find(a.opponent_sport_id).teams.find(a.opponent_team_id).team_logo(:thumb)
	else
		Sport.find(a.opponent_sport_id).sport_logo(:thumb)
	end
end 
node :eazesportzOpponent, :if => lambda { |a| a.opponent_team_id? } do
	true
end
node :opponentpic, :if => lambda { |a| !a.opponent_team_id? and a.opponentpic } do |a|
	a.opponentpic.url(:tiny)
end
node :opponentpicthumb, :if => lambda { |a| !a.opponent_team_id? and a.opponentpic } do |a|
	a.opponentpic.url(:thumb)
end

node :opponentpic_updated_at, :if => lambda { |a| !a.opponentpic_updated_at.nil? } do |a|
	a.opponentpic_updated_at
end
node(:starttime) { |t| t.starttime.strftime("%I:%M%p") }
node(:startdate) { |t| t.gamedate.strftime("%m-%d-%Y") }
node(:gamedatetime) { |t| t.starttime }
attributes :gamedate, :location, :opponent, :event, :homeaway, :game_name, :homeq1, :homeq2, :homeq3, :homeq4, :opponentq1, :opponentq2, 
		   :opponentq3, :opponentq4, :possession, :lastplay, :final, :opponent_mascot, :current_game_time, :currentperiod,
		   :opponent_name, :hometimeouts, :opponenttimeouts, :league, :opponent_sport_id, :opponent_team_id,
		   :opponent_league_wins, :opponent_league_losses, :opponent_nonleague_wins, :opponent_nonleague_losses
if @sport.name == "Football"
	node(:opponentscore) { |t| t.opponentq1 + t.opponentq2 + t.opponentq3 + t.opponentq4 }
	node(:homescore) { |t| footballhomescore(@sport, t) }
	node(:firstdowns) { |f| totalfirstdowns(@sport, f) }
	attributes :currentqtr, :penaltyyards, :down, :own, :ballon, :our, :togo, :penalty, :penaltyyards
	child :gamelogs do
		attributes :period, :time, :score, :logentry, :yards, :logentrytext
		node(:id) { |o| o.id.to_s }
		node :assist, :if => lambda { |g| !g.assist.nil? } do |g|
			g.assist
		end
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:football_passing_id) { |g| g.football_passing_id.to_s }
		node(:football_rushing_id) { |g| g.football_rushing_id.to_s }
		node(:football_returner_id) { |g| g.football_returner_id.to_s }
		node(:football_defense_id) { |g| g.football_defense_id.to_s }
		node(:football_place_kicker_id) { |g| g.football_place_kicker_id.to_s }
		node :hasphotos, :if => lambda { |a| !@sport.photos.where(gamelog_id: a.id.to_s).empty? } do
			true
		end
		node :hasvideos, :if => lambda { |a| !@sport.videoclips.where(gamelog_id: a.id.to_s).empty? } do
			true
		end
		node :player, :if => lambda { |p| p.football_passing_id } do |p|
			FootballPassing.find(p.football_passing_id).athlete_id.to_s
		end
		node :player, :if => lambda { |p| p.football_rushing_id } do |p|
			FootballRushing.find(p.football_rushing_id).athlete_id.to_s
		end
		node :player, :if => lambda { |p| p.football_returner_id } do |p|
			FootballReturner.find(p.football_returner_id).athlete_id.to_s
		end
		node :player, :if => lambda { |p| p.football_defense_id } do |p|
			FootballDefense.find(p.football_defense_id).athlete_id.to_s
		end
		node :player, :if => lambda { |p| p.football_place_kicker_id } do |p|
			FootballPlaceKicker.find(p.football_place_kicker_id).athlete_id.to_s
		end
	end
elsif @sport.name == "Basketball"
	attributes :opponentfouls, :homebonus, :visitorbonus, :opponentscore
	node(:homescore) { |g| basketball_home_score(@sport, g) }
	node(:homefouls) { |g| basketball_home_fouls(g) }
elsif @sport.name == "Soccer"

	child :soccer_game, :object_root => false do |sg|
		node(:soccer_game_id) { |s| s.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule.id.to_s }

		node :visiting_team_id, :if => lambda { |v| v.visiting_team } do |v|
			v.visiting_team.id.to_s
		end

		node(:soccergame_home_score) { sg.score(sport_home_team) }
		node(:soccergame_visitor_score) { sg.score(sport_visitor_team) }
		node(:soccergame_home_score_period1) { sg.periodscore(sport_home_team, 1) }
		node(:soccergame_home_score_period2) { sg.periodscore(sport_home_team, 2) }
		node(:soccergame_home_score_periodOT1) { sg.periodscore(sport_home_team, 3) }
		node(:soccergame_home_score_periodOT2) { sg.periodscore(sport_home_team, 4) }
		node(:soccergame_visitor_score_period1) { sg.periodscore(sport_visitor_team, 1) }
		node(:soccergame_visitor_score_period2) { sg.periodscore(sport_visitor_team, 2) }
		node(:soccergame_visitor_score_periodOT1) { sg.periodscore(sport_visitor_team, 3) }
		node(:soccergame_visitor_score_periodOT2) { sg.periodscore(sport_visitor_team, 4) }

		child :soccer_subs, :object_root => false do
			node(:soccer_sub_id) { |s| s.id.to_s }
			attributes :inplayer, :outplayer, :gametime
		end

		node(:soccer_home_shots) { sg.shots(sport_home_team) }
		node(:soccer_visitor_shots) { sg.shots(sport_visitor_team) }
		node(:soccergame_homecornerkicks) { sg.cornerkicks(sport_home_team) }
		node(:soccergame_visitorcornerkicks) { sg.cornerkicks(sport_visitor_team) }
		node(:soccergame_homesaves) { sg.saves(sport_home_team) }
		node(:soccergame_visitorsaves) { sg.saves(sport_visitor_team) }

		attributes :socceroppsog, :socceroppck, :socceroppsaves, :socceroppfouls, :homefouls, :visitorfouls, :homeoffsides, :visitoroffsides, 
					:homeplayers, :visitorplayers
	end

	attributes :socceroppck, :socceroppsog, :socceroppsaves, :opponentscore
	node(:homescore) { |g| soccer_home_score(@sport, g) }
elsif @sport.name == "Lacrosse"
	node(:lacrosse_home_score) { |g| get_lacrosse_home_score(g) }
	node(:lacrosse_home_score_by_period) { |g| get_lacrosse_home_score_by_period(g) }
	node(:lacrosse_visitor_score) { |g| get_lacrosse_visitor_score(g) }
	node(:lacrosse_visitor_score_by_period) { |g| get_lacrosse_visitor_score_by_period(g) }

	child :lacross_game, :object_root => false do
		node(:gameschedule_id) { |g| g.gameschedule.id.to_s }
		node(:lacross_game_id) { |g| g.id.to_s }

		node :visiting_team_id, :if => lambda { |v| v.visiting_team } do |v|
			v.visiting_team.id.to_s
		end

		attributes :clears, :failedclears, :visitor_clears, :visitor_failedclears, :free_position_sog, 
					:home_1stperiod_timeouts, :home_2ndperiod_timeouts, :visitor_1stperiod_timeouts, :visitor_2ndperiod_timeouts, :extraman_fail, :visitor_extraman_fail, :home_penaltyone_number, :home_penaltyone_minutes, :home_penaltyone_seconds, :home_penaltytwo_number, :home_penaltytwo_minutes, :home_penaltytwo_seconds, :visitor_penaltyone_number, :visitor_penaltyone_minutes, :visitor_penaltyone_seconds, :visitor_penaltytwo_number, :visitor_penaltytwo_minutes, :visitor_penaltytwo_seconds
	end
end
node :liveevent, :if => lambda { |e| !@sport.events.where(gameschedule_id: e.id.to_s, videoevent: 1).empty? } do
	true
end
