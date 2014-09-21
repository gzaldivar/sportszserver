module HockeyStatsHelper

	def hockey_penalties
		[
			["Butt Ending", "BE"],
			["Checking from Behind", "CB"],
			["Cross Checking", "CC"],
			["Elbowing", "E"], 
			["Fighting", "F"],
			["Hooking", "H"],
			["Interference", "I"],
			["Kneeing", "K"],
			["Roughing", "R"], 
			["Slashing", "SL"], 
			["Spearing", "SP"], 
			["Tripping", "T"]
		]
	end

	def hockey_positions
		[
			["Goalie", "G"],
			["Center", "C"],
			["Defensemen", "D"],
			["Right Wing", "RW"],
			["Left Wing", "LW"]
		]
	end

	def hockey_periods
        [
            ['1', '1'],
            ['2', '2'],
            ['3', '3'],
            ['OT', '4']
        ]
	end

end
