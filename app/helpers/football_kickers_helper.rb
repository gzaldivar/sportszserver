module FootballKickersHelper
	def isKicker?(stat)
		if stat.koattempts > 0
			true
		else
			false
		end
	end
end
