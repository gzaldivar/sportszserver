@ath_totals.each do |t|
	game = Gameschedule.find(t.gameschedule)
	child t => game.game_name do
		node(:id) { t.id.to_s }
		node(:game_id) { game.id.to_s }
		node(:gamename) { game.opponent }
		if !t.football_passings.nil?
			child t.football_passings => :passing do |a|
				attributes :attempts, :completions, :yards, :td, :sacks, :yards_lost, :interceptions, :twopointconv, :firstdowns
				node(:comp_percentage) { number_with_precision(a.comp_percentage, precision: 2) }
			end
		end
		if !t.football_rushings.nil?
			child t.football_rushings => :rushing do |a|
				attributes :attempts, :yards, :td, :longest, :fumbles, :fumbles_lost, :twopointconv, :firstdowns
				node(:average) { number_with_precision(a.average, precision: 2) }
			end
		end
		if !t.football_receivings.nil?
			child t.football_receivings => :receiving do |a|
				attributes :receptions, :yards, :td, :longest, :fumbles, :fumbles_lost, :twopointconv
				node(:average) { number_with_precision(a.average, precision: 2) }
			end
		end
		if !t.football_defenses.nil?
			child t.football_defenses => :defense do
				attributes :tackles, :assists, :sacks, :pass_defended, :interceptions, :int_yards, :int_long, :int_td, :fumbles_recovered,
						   :safety
			end
		end
		if !t.football_kickers.nil?
			child t.football_kickers => :placekicker do
				attributes :fgattempts, :fgmade, :fgblocked, :fglong, :xpattempts, :xpmade, :xpmissed, :xpblocked
			end
			child t.football_kickers => :kickoff do
				attributes :koattempts, :kotouchbacks, :koreturned
			end
			child t.football_kickers => :punter do
				attributes :punts, :punts_yards, :punts_long, :punts_blocked
			end
		end
		if !t.football_returners.nil?
			child t.football_returners => :punt_returner do
				attributes :punt_return, :punt_returnyards, :punt_returntd, :punt_returnlong
			end
			child t.football_returners => :kickoff_returner do
				attributes :koreturns, :kotd, :koyards, :kolong
			end
		end
	end
end
object @stats 
child @stats => :football_stats do
	child @stats => :passing_totals do
		attributes :passing_attempts, :passing_completions, :passing_yards, :passing_td, :passing_sacks, :passing_yards_lost, :passing_interceptions, 
				   :passing_tds, :passing_int, :passing_twopointconv
		node(:comp_percentage) { number_with_precision(@stats.passing_comp_percentage, precision: 2) }
	end
	child @stats => :rushing_totals do
		attributes :rushing_attempts, :rushing_yards, :rushing_tds, :rushing_longest, :rushing_fumbles, :rushing_fumbles_lost, :rushing_twopointconv
		node (:average) { number_with_precision(@stats.rushing_average, precision: 2) }
	end
	child @stats => :receiving_totals do
		attributes :receiving_receptions, :receiving_yards, :receiving_tds, :receiving_longest, :receiving_fumbles, :receiving_fumbles_lost,
				   :receiving_twopointconv
		node (:average) { number_with_precision(@stats.receiving_average, precision: 2) }
	end
	child @stats => :defense_totals do
		attributes :defense_tackles, :defense_assists, :defense_sacks, :defense_pass_defended, :defense_interceptions, :defense_int_yards,
				   :defense_int_long, :defense_int_td, :defense_fumbles_recovered, :defense_safety
	end
	child @stats => :placekicking_totals do
		attributes :kickers_fgattempts, :kickers_fgmade, :kickers_fgblocked, :kickers_fglong, :kickers_xpattempts, :kickers_xpmade, :kickers_xpmissed,
				   :kickers_xpblocked
	end
	child @stats => :kickoff_totals do
		attributes :kickers_koattempts, :kickers_kotouchbacks, :kickers_koreturned
	end
	child @stats => :punter_totals do
		attributes :kickers_punts, :kickers_punts_yards, :kickers_punts_long, :kickers_punts_blocked
	end
	child @stats => :kickoff_returner_totals do
		attributes :returners_koreturns, :returners_kotd, :returners_koyards, :returners_kolong
	end
	child @stats => :punt_returner_totals do
		attributes :returners_punt_return, :returners_punt_returnyards, :returners_punt_returntd, :returners_punt_returnlong
	end
end
