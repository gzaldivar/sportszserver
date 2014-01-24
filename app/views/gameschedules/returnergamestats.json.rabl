@returnerstats.each do |d|
	player = Athlete.find(d.athlete_id)
	if isPuntReturner?(d) or isKOReturner?(d)
		child d => player.logname do
			attribute :punt_return, :punt_returntd, :punt_returnlong, :punt_returnyards, :koreturns, :kotd, :kolong, :koyards
			node(:athlete_id) { |a| a.athlete_id.to_s }
		end
	end
end
child @returnertotals => :returnertotals do
	attribute :punt_return, :punt_returntd, :punt_returnlong, :punt_returnyards, :koreturns, :kotd, :kolong, :koyards
end
