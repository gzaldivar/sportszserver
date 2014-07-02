object @soccer_game
node(:soccer_game_id) { |s| s.id.to_s }
node(:visiting_team_id) { |v| v.visiting_team.to_s }
node(:gameschedule_id) { |g| g.gameschedule }

attributes :socceroppsog, :socceroppck, :socceroppsaves, :socceroppfouls, :homefouls, :visitorfouls, :homeoffsides, :visitoroffsides, 
			:homeplayers, :visitorplayers

