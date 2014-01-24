object @alert
node(:id) { |o| o.id.to_s }
attributes :message
node(:created_at) {|u| u.created_at.localtime.strftime('%m/%d/%Y %I:%M:%S %p') }
node(:user) { |u| u.user_id.to_s }
node(:athlete) { |u| u.athlete_id.to_s }
node(:photo) { |u| u.photo_id.to_s }
node(:videoclip) { |u| u.videoclip_id.to_s }
node(:blog) { |u| u.blog_id.to_s }
node(:sport) { |u| u.sport_id.to_s }
if @sport.name == "Football"
	node(:football_passing) { |u| u.football_passing_id.to_s }
	node(:football_rushing) { |u| u.football_rushing_id.to_s }
	node(:football_receiving) { |u| u.football_receiving_id.to_s }
	node(:football_place_kicker) { |u| u.football_place_kicker_id.to_s }
	node(:football_kicker) { |u| u.football_kicker_id.to_s }
	node(:football_punter) { |u| u.football_punter_id.to_s }
	node(:football_returner) { |u| u.football_returner_id.to_s }
	node(:football_defense) { |u| u.football_defense_id.to_s }
	node(:stat_football) { |s| s.stat_football }
elsif @sport.name == "Basketball"
	node(:basketball_stat) { |u| u.basketball_stat_id.to_s }
elsif @sport.name == "Soccer"
	node(:soccer) { |u| u.soccer_id.to_s }
end
