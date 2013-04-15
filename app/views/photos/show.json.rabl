object @photo
node(:id) { |o| o.id.to_s }
attributes :original_url,:large_url, :medium_url, :thumbnail_url, :displayname, :description, :teamid, :gameschedule, :owner, :players
