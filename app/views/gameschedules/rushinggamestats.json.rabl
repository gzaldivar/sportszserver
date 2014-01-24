@rushingstats.each do |r|
	player = Athlete.find(r.athlete_id)
	if r.attempts > 0
		child r => player.logname do
			attribute :attempts, :yards, :average, :td, :fumbles, :firstdowns, :longest, :fumbles_lost, :twopointconv
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @rushingtotals => :rushingtotals do
	attribute :attempts, :yards, :average, :td, :fumbles, :firstdowns, :longest, :fumbles_lost, :twopointconv
end
