module LacrossesHelper

	def lacrosse_positions
	    [
	      ['Attacker', 'A'],
	      ['Midfielder', 'M'],
	      ['Defender', 'D'],
	      ['Goalie', 'G']
	    ]
    end

    def lacrosse_score_codes
    	[
    		['B', 'Broken clear resulted in goal'],
    		['C', 'Cutter scored after receiving feed'],
    		['D', 'Doging goal'],
    		['F', 'Fast break goal'],
    		['O', 'Outside shot scored'],
    		['X', 'Extra man play scored']
    	]
    end

end
