object @photo
node(:id) { |o| o.id.to_s }
attributes :original_url,:large_url, :medium_url, :thumbnail_url, :displayname, :description, :teamid, :players
node(:user) { |o| o.user_id.to_s }
node(:gameschedule) { |o| o.gameschedule_id.to_s }
