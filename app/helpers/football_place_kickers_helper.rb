module FootballPlaceKickersHelper
	def isPlaceKicker?(stat)
		if stat.fgattempts > 0 or stat.xpattempts > 0
			true
		else
			false
		end
	end
end
