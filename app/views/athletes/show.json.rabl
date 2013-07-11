object @athlete
node(:id) { |o| o.id.to_s }
attributes :number, :name, :full_name, :logname, :lastname, :firstname, :middlename, :position, :height, :weight, :year, :bio, :season
node(:tiny) { |t| t.pic(:tiny) }
node(:thumb) { |t| t.pic(:thumb) }
node(:mediumpic) { |t| t.pic(:medium) }
node(:largepic) { |t| t.pic(:large) }
node(:team_id) { |t| t.team_id.to_s }
if !@team.nil? 
	node(:teamname) { @team.team_name }
end
node(:following) { |o| o.fans.include?(current_user.id) }
child :football_stats do
	node(:football_stat_id) { |f| f.id.to_s }
	node(:gamescheduleid) { |g| g.gameschedule_id.to_s }
	child :football_passings do
		node(:football_passing_id) { |f| f.id.to_s }
	end
	child :football_rushings do
		node(:football_rushing_id) { |f| f.id.to_s }
	end
	child :football_receivings do
		node(:football_receiving_id) { |f| f.id.to_s }
	end
	child :football_defenses do
		node(:football_defense_id) { |f| f.id.to_s }
	end
	child :football_kickers do
		node(:football_kicker_id) { |f| f.id.to_s }
	end
	child :football_returners do
		node(:football_returner_id) { |f| f.id.to_s }
	end
end
if lambda { |a| @sport.photos.where(players: a.id.to_s) }
	node(:hasphotos) { true }
end
if lambda { |a| @sport.videos.where(players: a.id.to_s) }
	node(:hasvideos) { true }
end