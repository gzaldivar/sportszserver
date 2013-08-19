object @blog
node(:id) { |o| o.id.to_s }
attributes :title, :entry, :external_url, :updated_at
node(:user) { |u| u.user_id.to_s }
node(:sport) { |t| t.sport_id.to_s }
node(:team) { |t| t.team_id.to_s }
node(:athlete) { |t| t.athlete_id.to_s }
node(:coach) { |t| t.coach_id.to_s }
node(:gameschedule) { |t| t.gameschedule_id.to_s }
node(:username) { |u| User.find(u.user).name }
node(:avatar) { |o| User.find(o.user).avatarthumburl }
node(:tinyavatar) { |o| User.find(o.user).avatartinyurl }
node(:gamelog) { |b| b.gamelog_id.to_s }