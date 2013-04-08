object @coach
node(:id) { |o| o.id.to_s }
attributes :lastname, :firstname, :middlename, :speciality, :years_on_staff, :bio, :team, :full_name
node(:thumb) { |t| t.coachpic(:thumb) }
node(:largepic) { |t| t.coachpic(:large) }
