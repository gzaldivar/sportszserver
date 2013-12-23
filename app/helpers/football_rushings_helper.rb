module FootballRushingsHelper
	def isRusher?(stat)
		if stat.attempts > 0
			true
		else
			false
		end
	end
end
