module SoccersHelper

  def is_soccer_goalie?(positions)
    if positions.include? "GK"
      return true
    else
      return false
    end
  end

  def hasSoccerPlayerStats?(stats)
  	player = false
    
  	if stats.kind_of?(Array)
  		stats.each do |s|
  			if s.goals > 0 or s.shotstaken > 0 or s.assists > 0 or s.steals > 0
  				player = true
  				break
  			end
  		end
  	elsif stats.goals > 0 or stats.shotstaken > 0 or stats.assists > 0 or stats.steals > 0
  		player = true
  	end
    
    return player
  end

end
