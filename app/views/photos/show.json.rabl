object @photo
node(:id) { |o| o.id.to_s }
attributes :large_url, :medium_url, :thumbnail_url, :displayname, :pending, :updated_at
node(:teamid) { |t| t.team_id.to_s }
attributes :description, :if => lambda { |m| !m.description.nil? }
attributes :players, :if => lambda { |m| !m.players.nil? }
node(:user) { |o| o.user_id.to_s }
node(:gameschedule) { |o| o.gameschedule_id.to_s }
node(:gamelog) { |o| o.gamelog_id.to_s }
node(:sport_id) { |s| s.sport_id.to_s }
node(:team_id) { |t| t.team_id.to_s }
