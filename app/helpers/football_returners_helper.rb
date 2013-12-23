module FootballReturnersHelper
	def isPuntReturner?(stat)
		if stat.punt_return > 0
			true
		else
			false
		end
	end

	def isKOReturner?(stat)
		if stat.koreturns > 0
			true
		else
			false
		end
	end	
end
