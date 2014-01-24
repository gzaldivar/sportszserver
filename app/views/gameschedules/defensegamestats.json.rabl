@defensivestats.each do |d|
	player = Athlete.find(d.athlete_id)
	if isDefense?(d)
		child d => player.logname do
			attribute :tackles, :assists, :sacks, :sackassist, :pass_defended, :interceptions, :int_yards, :int_long, :int_td, :fumbles_recovered, :safety
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @defensivetotals => :defensivetotals do
	attribute :tackles, :assists, :sacks, :sackassist, :pass_defended, :interceptions, :int_yards, :int_long, :int_td, :fumbles_recovered, :safety
end
