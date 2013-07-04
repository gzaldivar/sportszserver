object @user
node(:id) { |o| o.id.to_s }
attributes :season, :bio_alert, :blog_alert, :stat_alert, :score_alert, :media_alert, :name, :email, :is_active, :admin, 
					:default_site, :teamid, :authentication_token
node(:avatar) { |t| t.avatar(:thumb) }
node(:tiny) { |t| t.avatar(:tiny) }
node(:sitename) { |t| Sport.find(t.default_site).sitename }
node(:logo) { |t| Sport.find(t.default_site).sport_logo.url(:large) }
node(:banner_url) { |t| Sport.find(t.default_site).sport_banner.url(:thumb) }
