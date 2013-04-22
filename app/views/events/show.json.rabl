object @event
node(:id) { |o| o.id.to_s }
attributes :start_time, :end_time, :name, :desc
node(:user) { |u| u.user_id.to_s }
node(:team) { |u| u.team_id.to_s }
node(:sport) { |u| u.sport_id.to_s }

