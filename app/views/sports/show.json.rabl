object @sport
node(:id) { |o| o.id.to_s }
attributes :season, :name, :has_stats, :alert_interval, :gamelog_interval, :newsfeed_interval, :sitename, :mascot, :year, :zip, :beta, :approved,
					:silverMedia, :goldMedia, :platinumMedia, :city, :state, :country, :allstreams, :streamquality, :sdhdhighlights, :review_media,
					:enable_user_pics, :enable_user_video, :enablelive
node(:sport_logo_thumb) { |t| t.sport_logo(:thumb) }
node(:sport_logo_tiny) { |t| t.sport_logo(:tiny) }
node(:banner_url) { |b| b.sport_banner.url(:thumb) }
node(:teamcount) { |t| t.teams.count }

node :teamcount, :if => lambda { |a| a.teams.count == 0 } do
	"1"
end

if root_object.name == "Football"
	node(:football_offense_position) { offense_football_positions }
	node(:football_defense_position) { defense_football_positions } 
	node(:football_specialteams_position) { specialteams_football_positions }
elsif root_object.name == "Basketball"
	node(:basketball_positions) { basketball_positions }
elsif root_object.name == "Soccer"
	node(:soccer_positions) { soccer_positions }
	node(:soccer_yellowcard) { soccer_yellowcard }
	node(:soccer_redcard) { soccer_redcard }
elsif root_object.name == "Lacrosse"
	node(:lacrosse_positions) { lacrosse_positions }
	node(:lacrosse_score_codes) { lacrosse_score_codes }
	node(:lacrosse_shots) { lacrosse_shots }
	node(:lacrosse_periods) { lacrosse_periods }
	node(:lacrosse_personal_fouls) { lacrosse_personal_fouls }
	node(:lacrosse_technical_fouls) { lacrosse_technical_fouls }
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
node (:pricingurl) { admin.pricingurl }
node (:supportedsports) { admin.supportedsports }
node (:adurl) { admin.adurl }

node :purchaseads, :if => lambda { |s| User.find(s.adminid).paypal_email } do
	true
end
