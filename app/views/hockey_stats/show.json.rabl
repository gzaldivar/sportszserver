object @hockey_stat
node(:athlete_id) { |s| s.athlete_id.to_s }
node(:hockey_game_id) { |s| s.hockey_game_id.to_s }
node(:hockey_stat_id) { |s| s.id.to_s }

child :hockey_scorings, :object_root => false do
	node(:hockey_scoring_id) { |s| s.id.to_s }
	node(:hockey_stat_id) { |s| s.hockey_stat.id.to_s }
	node(:athlete_id) { |s| s.hockey_stat.athlete_id.to_s }
	attributes :gametime, :period, :game_winning_goal
	node(:scorelog) { |g| g.scorelog }

	node :assist, :if => lambda { |a| !a.assist.nil? } do |g|
		g.assist
	end

	node :assist_type, :if => lambda { |a| !a.assist_type.nil? } do |g|
		g.assist_type
	end

	child :photos, :object_root => false do |p|
		node(:id) { |p| p.id.to_s }
		attributes :displayname
	end
	
	child :videoclips, :object_root => false do |p|
		node(:id) { |p| p.id.to_s }
		attributes :displayname
	end
end

child :hockey_playerstats, :object_root => false do
	node(:hockey_playerstat_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.hockey_stat.athlete_id.to_s }
	node(:hockey_stat_id) { |s| s.hockey_stat.id.to_s }
	node(:visitor_roster_id) { |v| v.hockey_stat.visitor_roster_id.to_s }
	attributes :shots, :faceoffwon, :faceofflost, :period, :blockedshots, :plusminus, :hits, :timeonice
end

child :hockey_penalties, :object_root => false do
	node(:hockey_penalty_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.hockey_stat.athlete_id.to_s }
	node(:visitor_roster_id) { |v| v.hockey_stat.visitor_roster_id.to_s }
	node(:hockey_stat_id) { |s| s.hockey_stat.id.to_s }
	attributes :infraction, :gametime, :period, :penaltytime
end

child :hockey_goalstats, :object_root => false do
	node(:hockey_goalstat_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.hockey_stat.athlete_id.to_s }
	node(:visitor_roster_id) { |v| v.hockey_stat.visitor_roster_id.to_s }
	node(:hockey_stat_id) { |s| s.hockey_stat.id.to_s }
	attributes :saves, :minutesplayed, :goals_allowed, :period
end
