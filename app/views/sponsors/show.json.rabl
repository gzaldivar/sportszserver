object @sponsor
node(:id) { |o| o.id.to_s }
node(:teamid) { |o| o.team_id.to_s }
node(:sportadinv_id) { |s| s.sportadinv_id.to_s }
node(:ios_client_ad) { |s| s.ios_client_ad.to_s }
node(:user_id) { |s| s.user_id.to_s }
node(:athlete_id) { |s| s.athlete_id.to_s }
attributes :name, :addrnum, :street, :city,  :state,  :zip, :phone,  :fax,  :mobile,  :contactemail, :sponsorlevel, :teamonly, :adurl, :email
node :adsponsorlevel, :if => lambda { |a| !a.sportadinv.nil? } do |a|
	a.sportadinv.adlevelname
end
node :price, :if => lambda { |a| !a.sportadinv.nil? } do |a|
	a.sportadinv.price
end
node :forsale, :if => lambda { |a| !a.sportadinv.nil? } do |a|
	a.sportadinv.active
end
node :playerad, :if => lambda { |a| !a.sportadinv.nil? } do |a|
	a.sportadinv.playerad
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
