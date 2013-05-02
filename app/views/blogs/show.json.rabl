object @blog
node(:id) { |o| o.id.to_s }
attributes :title, :entry, :external_url
node(:sport) { |t| t.sport_id.to_s }
node(:team) { |t| t.team_id.to_s }
node(:athlete) { |t| t.athlete_id.to_s }
node(:coach) { |t| t.coach_id.to_s }
node(:gameschedule) { |t| t.gameschedule_id.to_s }
node(:user) { |o| User.find(o.user).name }
node(:avatar) { |o| User.find(o.user).avatar.url(:thumb) }