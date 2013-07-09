object @team
node(:id) { |o| o.id.to_s }
attributes :mascot, :title, :team_name
node(:team_logo) { |t| t.team_logo(:thumb) }
