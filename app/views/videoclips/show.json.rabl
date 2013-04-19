object @videoclip
node(:id) { |o| o.id.to_s }
attributes :video_url, :poster_url, :resolution, :duration, :displayname, :description, :teamid, :players
node(:user) { |o| o.id.to_s }
node(:gameschedule) { |o| o.id.to_s }
