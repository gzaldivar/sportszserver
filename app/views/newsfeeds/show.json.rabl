object @newsfeed
node(:id) { |o| o.id.to_s }
attributes :title, :news, :external_url, :gameschedule_id, :updated_at
node (:athlete_id) { |o| o.athlete_id.to_s }
node (:coach_id) { |o| o.coach_id.to_s }
node (:team_id) { |o| o.team_id.to_s }
node (:gameschedule_id) { |o| o.gameschedule_id.to_s }
