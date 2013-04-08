object @athlete
node(:id) { |o| o.id.to_s }
attributes :number, :name, :lastname, :firstname, :middlename, :position, :height, :weight, :year, :team, :bio
node(:thumb) { |t| t.pic(:thumb) }
node(:mediumpic) { |t| t.pic(:medium) }
node(:largepic) { |t| t.pic(:large) }
if !@team.nil? 
	node(:teamname) { @team.team_name }
end