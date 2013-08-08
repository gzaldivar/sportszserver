object @gamelog
node(:id) { |o| o.id.to_s }
attributes :period, :time, :logentrytext, :score, :logentry
node :hasphotos, :if => lambda { |a| !@sport.photos.where(gamelog_id: a.id.to_s).empty? } do
	true
end
node :hasvideos, :if => lambda { |a| !@sport.videoclips.where(gamelog_id: a.id.to_s).empty? } do
	true
end
