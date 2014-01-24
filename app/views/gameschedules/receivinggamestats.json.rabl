@receivingstats.each do |p|
	player = Athlete.find(p.athlete_id)
	if p.receptions > 0
		child p => player.logname do
			attribute :receptions, :yards, :average, :td, :longest, :fumbles, :fumbles_lost, :twopointconv, :firstdowns
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @receivingtotals => :receivingtotals do
	attribute :receptions, :yards, :average, :td, :longest, :fumbles, :fumbles_lost, :twopointconv, :firstdowns
end
