object @sport
node(:id) { |o| o.id.to_s }
attributes :season, :name, :has_stats, :alert_interval, :gamelog_interval, :newsfeed_interval, :sitename, :mascot, :year, :zip, :beta, :approved,
					:silverMedia, :goldMedia, :platinumMedia, :city, :state, :country, :allstreams, :streamquality, :sdhdhighlights
node(:sport_logo_thumb) { |t| t.sport_logo(:thumb) }
node(:sport_logo_tiny) { |t| t.sport_logo(:tiny) }
node(:banner_url) { |b| b.sport_banner.url(:thumb) }
node(:teamcount) { |t| t.teams.count }
if root_object.name == "Football"
	node(:football_offense_position) { offense_football_positions }
	node(:football_defense_position) { defense_football_positions } 
	node(:football_specialteams_position) { specialteams_football_positions }
end
if root_object.name == "Basketball"
	node(:basketball_positions) { basketball_positions }
end
if root_object.name == "Soccer"
	node(:soccer_positions) { soccer_positions }
end
node :package, :if => lambda { |s| !Payment.find_by(sport_id: s.id).nil? } do |a|
	Payment.find_by(sport_id: a.id).package
end
node :package, :if => lambda { |s| Payment.find_by(sport_id: s.id).nil? } do |a|
	"Basic"
end

admin = Admin.all.first
node (:streamingurl) { admin.streamingurl }
node (:streamingbucket) { admin.streamingbucket }
node (:broadcastAppVersion) { admin.broadcastAppVersion }
node (:highlightAppVersion) { admin.highlightAppVersion }
