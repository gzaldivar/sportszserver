object @sponsor
node(:id) { |o| o.id.to_s }
node(:teamid) { |o| o.team_id.to_s }
attributes :name, :addrnum, :street, :city,  :state,  :zip, :phone,  :fax,  :mobile,  :contactemail, :priority, :teamonly
node(:thumb) { |t| t.sponsorpic(:thumb) }
node(:mediumpic) { |t| t.sponsorpic(:medium) }
node(:largepic) { |t| t.sponsorpic(:large) }
