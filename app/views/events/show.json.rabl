object @event
node(:id) { |o| o.id.to_s }
attributes :start_time, :end_time, :name, :desc, :videoevent, :eventurl
node(:user_id) { |u| u.user_id.to_s }
node(:team_id) { |u| u.team_id.to_s }
node(:sport_id) { |u| u.sport_id.to_s }
node(:gameschedule_id) { |u| u.gameschedule_id.to_s }
