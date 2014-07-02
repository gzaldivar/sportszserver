object @soccer_stat
node(:athlete_id) { |s| s.athlete_id.to_s }
node(:soccer_game_id) { |s| s.id.to_s }
node(:visitor_roster_id) { |v| v.visitor_roster_id }

child :soccer_scorings, :object_root => false do
	node(:soccer_scoring_id) { |s| s.id.to_s }
	node(:photo_id) { |p| p.photo_id.to_s }
	node(:videoclip_id) { |v| v.videoclip_id.to_s }
	attributes :gametime,  :assist, :period
	node(:scorelog) { |g| g.scorelog }
end

child :soccer_playerstats, :object_root => false do
	node(:soccer_playerstat_id) { |s| s.id.to_s }
	attributes :shots, :steals, :cornerkick, :fouls, :period
end

child :soccer_penalties, :object_root => false do
	node(:soccer_penalty_id) { |s| s.id.to_s }
	attributes :infraction, :card, :gametime, :period
end

child :soccer_goalstats, :object_root => false do
	node(:soccer_goalstat_id) { |s| s.id.to_s }
	attributes :saves, :minutesplayed, :goals_allowed, :period
end

node(:player_shots) { |s| s.player_shots }
