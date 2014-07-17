object @soccer_stat
node(:athlete_id) { |s| s.athlete_id.to_s }
node(:soccer_game_id) { |s| s.soccer_game_id.to_s }
node(:visitor_roster_id) { |v| v.visitor_roster_id }
node(:soccer_stat_id) { |s| s.id.to_s }

child :soccer_scorings, :object_root => false do
	node(:soccer_scoring_id) { |s| s.id.to_s }
	node(:soccer_stat_id) { |s| s.soccer_stat.id.to_s }
	node(:athlete_id) { |s| s.soccer_stat.athlete_id.to_s }
	attributes :gametime, :period
	node(:scorelog) { |g| g.scorelog }

	node :assist, :if => lambda { |a| !a.assist.nil? } do |g|
		g.assist
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

child :soccer_playerstats, :object_root => false do
	node(:soccer_playerstat_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.soccer_stat.athlete_id.to_s }
	node(:soccer_stat_id) { |s| s.soccer_stat.id.to_s }
	node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
	attributes :shots, :steals, :cornerkick, :fouls, :period
end

child :soccer_penalties, :object_root => false do
	node(:soccer_penalty_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.soccer_stat.athlete_id.to_s }
	node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
	node(:soccer_stat_id) { |s| s.soccer_stat.id.to_s }
	attributes :infraction, :card, :gametime, :period
end

child :soccer_goalstats, :object_root => false do
	node(:soccer_goalstat_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.soccer_stat.athlete_id.to_s }
	node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
	node(:soccer_stat_id) { |s| s.soccer_stat.id.to_s }
	attributes :saves, :minutesplayed, :goals_allowed, :period
end
