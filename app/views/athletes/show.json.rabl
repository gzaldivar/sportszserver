object @athlete
node(:id) { |o| o.id.to_s }
attributes :number, :name, :full_name, :logname, :lastname, :firstname, :middlename, :position, :height, :weight, :year, :bio, :season, :processing
node(:tiny) { |t| t.pic(:tiny) }
node(:thumb) { |t| t.pic(:thumb) }
node(:mediumpic) { |t| t.pic(:medium) }
node(:largepic) { |t| t.pic(:large) }
node(:team_id) { |t| t.team_id.to_s }
node :pic_updated_at, :if => lambda { |a| !a.pic_updated_at.nil? } do |a|
	a.pic_updated_at
end
if !@team.nil? 
	node(:teamname) { @team.team_name }
end
if user_signed_in?
	node(:following) { |o| o.fans.include?(current_user.id) }
end
if @sport.name == "Football"
	child :football_passings do
		node(:football_passing_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :attempts, :completions, :yards, :td, :interceptions, :sacks, :yards_lost, :comp_percentage, :twopointconv, :firstdowns
	end
	child :football_rushings do
		node(:football_rushing_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :attempts, :yards, :average, :longest, :td, :fumbles, :fumbles_lost, :twopointconv, :firstdowns
	end
	child :football_receivings do
		node(:football_receiving_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :receptions, :yards, :average, :longest, :td, :fumbles, :fumbles_lost, :twopointconv, :firstdowns
	end
	child :football_defenses do
		node(:football_defense_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :tackles, :assists, :sacks, :pass_defended, :interceptions, :int_yards, :int_long, :int_td, :fumbles_recovered, :safety, :sackassist
	end
	child :football_kickers do
		node(:football_kicker_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes  :koattempts, :kotouchbacks, :koreturned, :koreturn_average
	end
	child :football_returners do
		node(:football_returner_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :punt_return, :punt_returntd, :punt_returnlong, :punt_returnyards, :koreturns, :kotd, :kolong, :koyards
	end
	child :football_place_kickers do
		node(:football_place_kicker_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :fgattempts, :fgmade, :fgblocked, :fglong, :xpattempts, :xpmade, :xpmissed, :xpblocked
	end
	child :football_punters do
		node(:football_punter_id) { |f| f.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		node(:athlete_id) { |g| g.athlete_id.to_s }
		attributes :punts, :punts_blocked, :punts_yards, :punts_long
	end
elsif @sport.name == "Basketball"
	child :basketball_stats do
		node(:basketball_stat_id) { |b| b.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		attributes :twoattempt, :twomade, :threeattempt, :threemade, :ftmade, :ftattempt, :fouls, :assists, :steals, :blocks, :offrebound, 
					:defrebound, :turnovers
	end
elsif @sport.name == "Soccer"
	child :soccers do
		node(:soccerid) { |s| s.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		attributes :goals, :shotstaken, :assists, :steals, :goalsagainst, :goalssaved, :shutouts, :minutesplayed, :cornerkick
	end

	child :soccer_stats, :object_root => false do
		extends 'soccer_stats/show'
	end
elsif @sport.name == "Water Polo"
	child :waterpolo_stats, :object_root => false do
		extends 'waterpolo_stats/show'
	end
elsif @sport.name == "Lacrosse"
	child :lacrosstats, :object_root => false do
		node(:lacrosstat_id) { |l| l.id.to_s }
		node(:athlete_id) { |a| a.athlete_id.to_s }
		node(:lacross_game_id) { |g| g.lacross_game_id.to_s }
		node(:visitor_roster) { |v| v.visitor_roster_id.to_s }

		child :lacross_scorings, :object_root => false do
			node(:lacross_scoring_id) { |s| s.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			attributes :gametime, :scorecode, :period
			node :assist, :if => lambda { |a| !a.assist.nil? } do |g|
				g.assist
			end
			child :photos, :object_root => false do |p|
				node(:id) { |p| p.id.to_s }
				attributes :displayname
			end
			child :videoclips, :object_root => false do |p|
				node(:id) { |p| p.id.to_s }
				attributes :displayname
			end
		end

		child :lacross_player_stats, :object_root => false do
			node(:lacross_player_stat_id) { |s| s.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			attributes :shot, :face_off_won, :face_off_lost, :face_off_violation, :ground_ball, :interception, :turnover, :caused_turnover, :steals, :period
		end

		child :lacross_penalties, :object_root => false do
			node(:lacross_penalty_id) { |s| s.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			attributes :infraction, :type, :gametime, :type, :period
		end

		child :lacross_goalstats, :object_root => false do
			node(:lacross_goalstat_id) { |g| g.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			attributes :saves, :minutesplayed, :goals_allowed, :period
		end
	end
end
node :hasphotos, :if => lambda { |a| !@sport.photos.where(players: a.id.to_s).empty? } do
	true
end
node :hasvideos, :if => lambda { |a| !@sport.videoclips.where(players: a.id.to_s).empty? } do
	true
end