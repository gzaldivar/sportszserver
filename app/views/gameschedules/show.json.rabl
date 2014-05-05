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
node :opponentpic, :if => lambda { |a| !a.opponent_team_id? and a.opponentpic? } do |a|
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
		   :opponentq3, :opponentq4, :possession, :lastplay, :final, :opponent_mascot, :current_game_time,
		   :opponent_name, :hometimeouts, :opponenttimeouts, :league, :opponent_sport_id, :opponent_team_id,
		   :opponent_league_wins, :opponent_league_losses, :opponent_nonleague_wins, :opponent_nonleague_losses
if @sport.name == "Football"
	node(:opponentscore) { |t| t.opponentq1 + t.opponentq2 + t.opponentq3 + t.opponentq4 }
	node(:homescore) { |t| footballhomescore(@sport, t) }
	node(:firstdowns) { |f| totalfirstdowns(@sport, f) }
	attributes :currentqtr, :penaltyyards, :down, :own, :ballon, :our, :togo, :penalty, :penaltyyards, :currentperiod
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
	attributes :opponentfouls, :currentperiod, :homebonus, :visitorbonus, :opponentscore
	node(:homescore) { |g| basketball_home_score(@sport, g) }
	node(:homefouls) { |g| basketball_home_fouls(g) }
elsif @sport.name == "Soccer"
	attributes :socceroppck, :socceroppsog, :socceroppsaves, :currentperiod, :opponentscore
	node(:homescore) { |g| soccer_home_score(@sport, g) }
end
node :liveevent, :if => lambda { |e| !@sport.events.where(gameschedule_id: e.id.to_s, videoevent: 1).empty? } do
	true
end
