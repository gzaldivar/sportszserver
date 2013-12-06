object @team
node(:id) { |o| o.id.to_s }
attributes :mascot, :title, :team_name
node(:team_logo) { |t| t.team_logo(:thumb) }
node(:tiny_logo) { |t| t.team_logo(:tiny) }
if @sport.name == "Football"
	attributes :fb_rush_players, :if => lambda { |m| !m.fb_rush_players.nil? }
	attributes :fb_rec_players, :if => lambda { |m| !m.fb_rec_players.nil? }
	attributes :fb_def_players, :if => lambda { |m| !m.fb_def_players.nil? }
	attributes :fb_pass_players, :if => lambda { |m| !m.fb_pass_players.nil? }
	attributes :fb_returners, :if => lambda { |m| !m.fb_returners.nil? }
	attributes :fb_placekickers, :if => lambda { |m| !m.fb_placekickers.nil? }
	attributes :fb_kickers, :if => lambda { |m| !m.fb_kickers.nil? }
	attributes :fb_punters, :if => lambda { |m| !m.fb_punters.nil? }	
end
