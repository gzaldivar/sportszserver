object @gameschedule
node(:id) { |o| o.id.to_s }
node(:opponentpic) { |t| t.opponentpic(:tiny) }
node(:starttime) { |t| t.starttime.strftime("%I:%M%p") }
node(:current_game_time) { |t| t.livegametime.strftime("%I:%M") }
attributes :gamedate, :location, :opponent, :event, :homeaway, :game_name, :homeq1, :homeq2, :homeq3, :homeq4, :opponentq1, :opponentq2, 
		   :opponentq3, :opponentq4, :possession, :lastplay, :final, :opponent_mascot, 
		   :opponent_name, :homescore, :opponentscore, :hometimeouts, :opponenttimeouts, :league
if @sport.name == "Football"
	node(:firstdowns) { |f| f.firstdowns }
	attributes :currentqtr, :penaltyyards, :down, :own, :ballon, :our, :togo, :penalty, :penaltyyards
	if !@stats.nil?
		extends 'gameschedules/stats'
	end
	child :gamelogs do
		attributes :period, :time, :score, :logentry, :yards, :player
		attributes :logentrytext, :if => lambda { |m| !m.player.nil? and !m.player.blank? }
		node(:id) { |o| o.id.to_s }
		node :hasphotos, :if => lambda { |a| !@sport.photos.where(gamelog_id: a.id.to_s).empty? } do
			true
		end
		node :hasvideos, :if => lambda { |a| !@sport.videoclips.where(gamelog_id: a.id.to_s).empty? } do
			true
		end
	end
elsif @sport.name == "Basketball"
	attributes :opponentfouls, :currentperiod, :homefouls
end
