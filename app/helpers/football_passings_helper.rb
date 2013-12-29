module FootballPassingsHelper

	def isPasser?(stat)
		if stat.attempts > 0 or (!stat.gameqb.nil? and stat.gameqb)
			true
		else
			false
		end
	end
	
end
