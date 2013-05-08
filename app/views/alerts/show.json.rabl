object @alert
node(:id) { |o| o.id.to_s }
attributes :message, :stat_football
node(:created_at) {|u| u.created_at.strftime('%m/%d/%Y %I:%M:%S %p') }
node(:user) { |u| u.user_id.to_s }
node(:athlete) { |u| u.athlete_id.to_s }
node(:photo) { |u| u.photo_id.to_s }
node(:videoclip) { |u| u.videoclip_id.to_s }
node(:blog) { |u| u.blog_id.to_s }
node(:sport) { |u| u.sport_id.to_s }
node(:football_stat) { |u| u.football_stat_id.to_s }
if @sport.sportname == "Football"
	node(:stat_football) { |s| s.stat_football }
end
