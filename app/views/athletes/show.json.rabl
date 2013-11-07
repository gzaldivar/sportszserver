object @athlete
node(:id) { |o| o.id.to_s }
attributes :number, :name, :full_name, :logname, :lastname, :firstname, :middlename, :position, :height, :weight, :year, :bio, :season, :processing
node(:tiny) { |t| t.pic(:tiny) }
node(:thumb) { |t| t.pic(:thumb) }
node(:mediumpic) { |t| t.pic(:medium) }
node(:largepic) { |t| t.pic(:large) }
node(:team_id) { |t| t.team_id.to_s }
if !@team.nil? 
	node(:teamname) { @team.team_name }
end
node(:following) { |o| o.fans.include?(current_user.id) }
if @sport.name == "Football"
	child :football_stats do
		node(:football_stat_id) { |f| f.id.to_s }
		node(:gamescheduleid) { |g| g.gameschedule_id.to_s }
		child :football_passings do
			node(:football_passing_id) { |f| f.id.to_s }
			attributes :attempts, :completions, :yards, :td, :interceptions, :sacks, :yards_lost, :comp_percentage, :twopointconv, :firstdowns
		end
		child :football_rushings do
			node(:football_rushing_id) { |f| f.id.to_s }
		end
		child :football_receivings do
			node(:football_receiving_id) { |f| f.id.to_s }
			attributes :receptions, :yards, :average, :longest, :td, :fumbles, :fumbles_lost, :twopointconv
		end
		child :football_defenses do
			node(:football_defense_id) { |f| f.id.to_s }
			attributes :tackles, :assists, :sacks, :pass_defended, :interceptions, :int_yards, :int_long, :int_td, :fumbles_recovered, :safety
		end
		child :football_kickers do
			node(:football_kicker_id) { |f| f.id.to_s }
			attributes :fgattempts, :fgmade, :fgblocked, :fglong, :xpattempts, :xpmade, :xpmissed, :xpblocked, :koattempts, :kotouchbacks, :koreturned,
			 						:koreturn_average, :punts, :punts_blocked, :punts_yards, :punts_long
		end
		child :football_returners do
			node(:football_returner_id) { |f| f.id.to_s }
			attributes :punt_return, :punt_returntd, :punt_returnlong, :punt_returnyards, :koreturns, :kotd, :kolong, :koyards
		end
	end
elsif @sport.name == "Basketball"
	child :basketball_stats do
		node(:basketball_stat_id) { |b| b.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		attributes :twoattempt, :twomade, :threeattempt, :threemade, :ftmade, :ftattempt, :fouls, :assists, :steals, :blocks, :offrebound, :defrebound
	end
elsif @sport.name == "Soccer"
	child :soccers do
		node(:soccerid) { |s| s.id.to_s }
		node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
		attributes :goals, :shotstaken, :assists, :steals, :goalsagainst, :goalssaved, :shutouts, :minutesplayed, :cornerkick
	end
end
node :hasphotos, :if => lambda { |a| !@sport.photos.where(players: a.id.to_s).empty? } do
	true
end
node :hasvideos, :if => lambda { |a| !@sport.videoclips.where(players: a.id.to_s).empty? } do
	true
end