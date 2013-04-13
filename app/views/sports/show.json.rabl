object @sport
node(:id) { |o| o.id.to_s }
attributes :season, :name, :sex
node(:sport_logo) { |t| t.sport_logo(:large) }
child :teams do
	attributes :title, :mascot, :team_name
	node (:teamid) { |o| o.id.to_s }
end
child :sponsors do
	node(:id) { |o| o.id.to_s }
	node(:teamid) { |o| o.team_id.to_s }
	attributes :name, :addrnum, :street, :city, :state, :zip, :phone, :fax, :mobile, :contactemail, :priority, :teamonly
	node(:thumb) { |t| t.sponsorpic(:thumb) }
	node(:mediumpic) { |t| t.sponsorpic(:medium) }
	node(:largepic) { |t| t.sponsorpic(:large) }
end