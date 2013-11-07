object @sport
node(:id) { |o| o.id.to_s }
attributes :season, :name, :has_stats, :alert_interval, :gamelog_interval, :newsfeed_interval, :sitename, :mascot, :year, :zip, :beta, :approved
node(:sport_logo) { |t| t.sport_logo(:large) }
node(:sport_logo_thumb) { |t| t.sport_logo(:thumb) }
node(:sport_logo_medium) { |t| t.sport_logo(:medium) }
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
