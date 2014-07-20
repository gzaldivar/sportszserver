object @waterpolo_stat
node(:athlete_id) { |s| s.athlete_id.to_s }
node(:water_polo_game_id) { |s| s.water_polo_game_id.to_s }
node(:visitor_roster_id) { |v| v.visitor_roster_id }
node(:waterpolo_stat_id) { |s| s.id.to_s }

child :waterpolo_scorings, :object_root => false do
	node(:waterpolo_scoring_id) { |s| s.id.to_s }
	node(:waterpolo_stat_id) { |s| s.waterpolo_stat.id.to_s }
	node(:athlete_id) { |s| s.waterpolo_stat.athlete_id.to_s }
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

child :waterpolo_playerstats, :object_root => false do
	node(:waterpolo_playerstat_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.waterpolo_stat.athlete_id.to_s }
	node(:waterpolo_stat_id) { |s| s.waterpolo_stat.id.to_s }
	node(:visitor_roster_id) { |v| v.waterpolo_stat.visitor_roster_id.to_s }
	attributes :shots, :steals, :fouls, :period
end

child :waterpolo_penalties, :object_root => false do
	node(:waterpolo_penalty_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.waterpolo_stat.athlete_id.to_s }
	node(:visitor_roster_id) { |v| v.waterpolo_stat.visitor_roster_id.to_s }
	node(:waterpolo_stat_id) { |s| s.waterpolo_stat.id.to_s }
	attributes :infraction, :card, :gametime, :period
end

child :waterpolo_goalstats, :object_root => false do
	node(:waterpolo_goalstat_id) { |s| s.id.to_s }
	node(:athlete_id) { |s| s.waterpolo_stat.athlete_id.to_s }
	node(:visitor_roster_id) { |v| v.waterpolo_stat.visitor_roster_id.to_s }
	node(:waterpolo_stat_id) { |s| s.waterpolo_stat.id.to_s }
	attributes :saves, :minutesplayed, :goals_allowed, :period
end
