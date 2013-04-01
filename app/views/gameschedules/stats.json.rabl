child :football_stats do
	child :football_passings do
		attributes :attempts, :completions, :comp_percentage, :td, :sacks, :yards_lost, :interceptions
	end
	child :football_rushings do
		attributes :attempts, :yards, :average, :td, :longest, :fumbles, :fumbles_lost
	end
	child :football_receivings do
		attributes :receptions, :yards, :average, :longest, :td, :fumbles, :fumbles_lost
	end
	child :football_defenses do
		attributes :tackles, :assists, :sacks, :pass_defended, :interceptions, :int_yards, :int_long, :int_td, :fumbles_recovered
	end
	child :football_specialteams do
		attributes :fgattempts, :fgmade, :fgblocked, :fglong, :xpattempts, :xpmade, :xpmissed, :xpblocked, :koattempts, :kotouchbacks,
				   :koreturned, :punts, :punts_blocked, :punts_yards, :punts_long, :punt_return, :punt_returntd, :punt_returnlong, :punt_returnyards, :koreturns, :kotd, :kolong, :koyards
	end
end
