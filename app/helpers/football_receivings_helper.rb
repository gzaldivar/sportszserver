module FootballReceivingsHelper
	def isReceiver?(stat)
		if stat.receptions > 0
			true
		else
			false
		end
	end
end
