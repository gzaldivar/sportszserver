object @sport
node(:id) { |o| o.id.to_s }
attributes :season, :name, :sex
node(:sport_logo) { |t| t.sport_logo(:large) }