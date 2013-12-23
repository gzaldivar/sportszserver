module FootballDefensesHelper
	def isDefense?(stat)
		if stat.tackles > 0 or stat.assists > 0 or stat.int_td > 0 or stat.sacks > 0 or stat.sackassist > 0 or stat.pass_defended > 0 or 
			stat.fumbles_recovered > 0 or stat.safety > 0
			true
		else
			false
		end
	end
end
