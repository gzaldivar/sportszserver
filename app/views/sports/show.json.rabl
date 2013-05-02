object @sport
node(:id) { |o| o.id.to_s }
attributes :season, :name, :has_stats, :alert_interval, :gamelog_interval, :newsfeed_interval, :sitename, :mascot
node(:sport_logo) { |t| t.sport_logo(:large) }
node(:banner_url) { |b| b.sport_banner.url(:thumb) }
child :teams do
	attributes :title, :mascot, :team_name
	node (:id) { |o| o.id.to_s }
	node(:team_logo) { |t| t.team_logo(:thumb) }
end
child :sponsors do
	node(:id) { |o| o.id.to_s }
	node(:team_id) { |o| o.team_id.to_s }
	attributes :name, :addrnum, :street, :city, :state, :zip, :phone, :fax, :mobile, :contactemail, :priority, :teamonly
	node(:thumb) { |t| t.sponsorpic(:thumb) }
	node(:mediumpic) { |t| t.sponsorpic(:medium) }
	node(:largepic) { |t| t.sponsorpic(:large) }
end