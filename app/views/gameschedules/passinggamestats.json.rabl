@passingstats.each do |p|
	player = Athlete.find(p.athlete_id)
	if p.attempts > 0
		child p => player.logname do
			attribute :attempts, :completions, :yards, :comp_percentage, :td, :interceptions, :sacks, :yards_lost, :twopointconv
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @passingtotals => :passingtotals do
	attribute :attempts, :completions, :yards, :comp_percentage, :td, :interceptions, :sacks, :yards_lost, :twopointconv
end
