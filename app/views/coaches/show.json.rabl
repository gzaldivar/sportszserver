object @coach
node(:id) { |o| o.id.to_s }
attributes :lastname, :firstname, :middlename, :speciality, :years_on_staff, :bio, :full_name, :processing
node(:team_id) { |t| t.team_id.to_s }
node(:thumb) { |t| t.coachpic(:thumb) }
node(:tiny) { |t| t.coachpic(:tiny) }
node(:medium) { |t| t.coachpic(:medium) }
