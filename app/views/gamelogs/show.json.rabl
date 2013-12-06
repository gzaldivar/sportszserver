object @gamelog
node(:id) { |o| o.id.to_s }
node(:gameschedule_id) { |g| g.id.to_s }
node(:football_passing_id) { |g| g.football_passing_id.to_s }
node(:football_rushing_id) { |g| g.football_rushing_id.to_s }
node(:football_returner_id) { |g| g.football_returner_id.to_s }
node(:football_defense_id) { |g| g.football_defense_id.to_s }
node(:football_place_kicker_id) { |g| g.football_place_kicker_id.to_s }
attributes :period, :time, :logentrytext, :score, :logentry, :player, :assist, :yards
node :hasphotos, :if => lambda { |a| !@sport.photos.where(gamelog_id: a.id.to_s).empty? } do
	true
end
node :hasvideos, :if => lambda { |a| !@sport.videoclips.where(gamelog_id: a.id.to_s).empty? } do
	true
end
