module FootballPassingsHelper

	def isPasser?(stat)
		if stat.attempts > 0
			true
		else
			false
		end
	end
end
