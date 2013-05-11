object @photo
node(:id) { |o| o.id.to_s }
attributes :large_url, :medium_url, :thumbnail_url, :displayname, :teamid
attributes :description, :if => lambda { |m| !m.description.nil? }
attributes :players, :if => lambda { |m| !m.players.nil? }
node(:user) { |o| o.user_id.to_s }
node(:gameschedule) { |o| o.gameschedule_id.to_s }
