collection @blogs
attributes :title, :entry
node(:sport) { |t| t.sport_id.to_s }
node(:team) { |t| t.team_id.to_s }
node(:athlete) { |t| t.athlete_id.to_s }
node(:coach) { |t| t.coach_id.to_s }
node(:gameschedule) { |t| t.gameschedule_id.to_s }
node(:id) { |o| o.id.to_s }
node(:user) { |o| User.find(o.user_id).name }
