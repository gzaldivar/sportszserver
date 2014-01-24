@placekickerstats.each do |d|
	player = Athlete.find(d.athlete_id)
	if isPlaceKicker?(d)
		child d => player.logname do
			attribute :fgattempts, :fgmade, :fgblocked, :fglong, :xpattempts, :xpmade, :xpmissed, :xpblocked
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @placekickertotals => :placekickertotals do
	attribute :fgattempts, :fgmade, :fgblocked, :fglong, :xpattempts, :xpmade, :xpmissed, :xpblocked
end
@punterstats.each do |d|
	player = Athlete.find(d.athlete_id)
	if isPunter?(d)
		child d => player.logname do
			attribute :punts, :punts_blocked, :punts_yards, :punts_long
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @puntertotals => :puntertotals do
	attribute :punts, :punts_blocked, :punts_yards, :punts_long
end
