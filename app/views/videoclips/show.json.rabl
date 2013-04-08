object @videoclip
node(:id) { |o| o.id.to_s }
attributes :video_url, :poster_url, :resolution, :duration, :displayname, :description, :teamid, :schedule, :owner, :players
