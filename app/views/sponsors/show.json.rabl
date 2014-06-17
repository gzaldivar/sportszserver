object @sponsor
node(:id) { |o| o.id.to_s }
node(:teamid) { |o| o.team_id.to_s }
node(:sportadinv_id) { |s| s.sportadinv_id.to_s }
node(:ios_client_ad) { |s| s.ios_client_ad_id.to_s }
node(:user_id) { |s| s.user_id.to_s }
node(:athlete_id) { |s| s.athlete_id.to_s }

node :street, :if => lambda { |s| !s.street.nil? }
node :city, :if => lambda { |s| !s.city.nil? }
node :state, :if => lambda { |s| !s.state.nil? }
node :zip, :if => lambda { |s| !s.zip.nil? }
node :phone, :if => lambda { |s| !s.phone.nil? }
node :fax, :if => lambda { |s| !s.fax.nil? }
node :mobile, :if => lambda { |s| !s.mobile.nil? }
node :contactemail, :if => lambda { |s| !s.contactemail.nil? }
node :sponsorlevel, :if => lambda { |s| !s.sponsorlevel.nil? }
node :adurl, :if => lambda { |s| !s.adurl.nil? }

attributes :name, :addrnum, :teamonly
node :adsponsorlevel, :if => lambda { |a| !a.sportadinv.nil? } do |a|
	a.sportadinv.adlevelname
end
node :price, :if => lambda { |a| !a.sportadinv.nil? or !a.ios_client_ad.nil? } do |a|
	if a.sportadinv
		a.sportadinv.price
	else
		a.ios_client_ad.price
	end
end
node :forsale, :if => lambda { |a| !a.sportadinv.nil? } do |a|
	a.sportadinv.active
end
node :playerad, :if => lambda { |a| (!a.sportadinv.nil? and a.sportadinv.playerad == true ) or 
									(!a.ios_client_ad.nil? and a.ios_client_ad.playerad == true) } do |a|
	true
end
node :thumb, :if => lambda { |t| t.sponsorpic? } do |s|
	s.sponsorpic(:thumb)
end
node :medium, :if => lambda { |t| t.sponsorpic? } do |s|
	s.sponsorpic(:medium)
end
node :large, :if => lambda { |t| t.sponsorpic? } do |s|
	s.sponsorpic(:large)
end
node :tiny, :if => lambda { |t| t.sponsorpic? }  do |s|
	s.sponsorpic(:tiny)
end
node :portraitbanner, :if => lambda { |s| s.adbanner? } do |s|
	s.adbanner(:portraitbanner)
end
node :landscapebanner, :if => lambda { |s| s.adbanner? } do |s|
	s.adbanner(:landscapebanner)
end
node :sponsorpic_updated_at, :if => lambda { |s| s.sponsorpic? } do |s|
	s.sponsorpic_updated_at
end
node :adbanner_updated_at, :if => lambda { |s| s.adbanner? } do |s|
	s.adbanner_updated_at
end
