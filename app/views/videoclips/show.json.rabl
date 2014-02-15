object @videoclip
node(:id) { |o| o.id.to_s }
attributes :video_url, :poster_url, :resolution, :duration, :displayname, :size, :width, :height
attributes :description, :if => lambda { |m| !m.description.nil? }
attributes :players, :if => lambda { |m| !m.players.nil? }
node(:user_id) { |o| o.user_id.to_s }
node(:gameschedule) { |o| o.gameschedule_id.to_s }
node(:gamelog) { |o| o.gamelog_id.to_s }
node(:teamid) { |t| t.team_id.to_s }
