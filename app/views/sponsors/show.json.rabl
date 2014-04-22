if is_platinum?
	object @sponsor
	node(:id) { |o| o.id.to_s }
	node(:teamid) { |o| o.team_id.to_s }
	attributes :name, :addrnum, :street, :city,  :state,  :zip, :phone,  :fax,  :mobile,  :contactemail, :sponsorlevel, :teamonly, :adurl, :email
	node :adsponsorlevel, :if => lambda { |a| !a.sportadinv.nil? } do |a|
		a.sportadinv.adlevelname
	end
	node :adsponsorprice, :if => lambda { |a| !a.sportadinv.nil? } do |a|
		a.sportadinv.price
	end
	node :adsponsoractive, :if => lambda { |a| !a.sportadinv.nil? } do |a|
		a.sportadinv.active
	end
	node(:thumb) { |t| t.sponsorpic(:thumb) }
	node(:medium) { |t| t.sponsorpic(:medium) }
	node(:large) { |t| t.sponsorpic(:large) }
	node(:tiny) { |t| t.sponsorpic(:tiny) }
end
