if !@receiving.nil?
	node (:receptions) { @receiving.receiving_receptions }
	node (:yards) { @receiving.receiving_yards }
	node (:average) { @receiving.receiving_average }
	node (:tds) { @receiving.receiving_tds }
	node (:longest) { @receiving.receiving_longest }
	node (:fumbles) { @receiving.receiving_fumbles }
	node (:fumbles_lost) { @receiving.receiving_fumbles_lost }
end