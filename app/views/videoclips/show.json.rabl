object @videoclip
node(:id) { |o| o.id.to_s }
attributes :video_url, :poster_url, :resolution, :duration, :displayname, :description, :teamid, :players
node(:user_id) { |o| o.user_id.to_s }
node(:gameschedule) { |o| o.gameschedule_id.to_s }
node(:gamelog) { |o| o.gamelog_id.to_s }
