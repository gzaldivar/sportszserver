object @newsfeed
node(:id) { |o| o.id.to_s }
attributes :title, :news, :gameschedule_id, :updated_at
node :external_url, :if => lambda { |n| !n.external_url.nil? } do |n|
	n.external_url
end
node (:athlete_id) { |o| o.athlete_id.to_s }
node (:coach_id) { |o| o.coach_id.to_s }
node (:team_id) { |o| o.team_id.to_s }
node (:gameschedule_id) { |o| o.gameschedule_id.to_s }
node (:videoclip_id) { |n| n.videoclip_id.to_s } 
node :tinyurl, :if => lambda { |n| n.newsfeedpic.file? } do |n|
	n.newsfeedpic.url(:tiny)
end
node :thumburl, :if => lambda { |n| n.newsfeedpic.file? } do |n|
	n.newsfeedpic.url(:thumb)
end
