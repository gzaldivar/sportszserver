module FootballPuntersHelper
	def isPunter?(stat)
		if stat.punts > 0
			true
		else
			false
		end
	end
end
