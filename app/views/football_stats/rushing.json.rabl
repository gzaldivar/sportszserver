if !@rushing.nil?
	node (:attempts) { @rushing.rushing_attempts }
	node (:yards) { @rushing.rushing_yards }
	node (:average) { @rushing.rushing_average }
	node (:tds) { @rushing.rushing_tds }
	node (:longest) { @rushing.rushing_longest }
	node (:fumbles) { @rushing.rushing_fumbles }
	node (:fumbles_lost) { @rushing.rushing_fumbles_lost }
end