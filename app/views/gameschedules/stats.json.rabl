if !@stats.nil?
	child :football_stats do
		child :football_passings do
			node (:attempts) { @stats.passing_attempts }
			node (:completions) { @stats.passing_completions }
			node (:comp_percentage) { @stats.passing_comp_percentage }
			node (:yards) { @stats.passing_yards }
			node (:tds) { @stats.passing_tds }
			node (:int) { @stats.passing_int }
			node (:sacks) { @stats.passing_sacks }
			node (:yards_lost) { @stats.passing_yards_lost }
		end
		child :football_rushings do
			node (:attempts) { @stats.rushing_attempts }
			node (:average) {@stats.rushing_average }
			node (:yards) { @stats.rushing_yards }
			node (:average) { @stats.rushing_average }
			node (:tds) { @stats.rushing_tds }
			node (:longest) { @stats.rushing_longest }
			node (:fumbles) { @stats.rushing_fumbles }
			node (:fumbles_lost) { @stats.rushing_fumbles_lost }
		end
		child :football_receivings do
			node (:receptions) { @stats.receiving_receptions }
			node (:yards) { @stats.receiving_yards }
			node (:average) { @stats.receiving_average}
			node (:tds) { @stats.receiving_tds }
			node (:longest) { @stats.receiving_longest }
			node (:fumbles) { @stats.receiving_fumbles }
			node (:fumbles_lost) { @stats.receiving_fumbles_lost }
		end
		child :football_defenses do
			node (:tackles) { @stats.defense_tackles }
			node (:assists) { @stats.defense_assists }
			node (:sacks) { @stats.defense_sacks }
			node (:pass_defended) { @stats.defense_pass_defended }
			node (:interceptions) { @stats.defense_interceptions }
			node (:int_yards) { @stats.defense_int_yards }
			node (:int_long) { @stats.defense_int_long }
			node (:tds) { @stats.defense_int_td }
			node (:fumbles_recovered) { @stats.defense_fumbles_recovered }
		end
		child :football_specialteams do
			node (:fgattempts) { @stats.specialteams_fgattempts }
			node (:fgmade) { @stats.specialteams_fgmade }
			node (:fgblocked) { @stats.specialteams_fgblocked }
			node (:fglong) { @stats.specialteams_fglong }
			node (:xpattempts) { @stats.specialteams_xpattempts }
			node (:xpmade) { @stats.specialteams_xpmade }
			node (:xpmissed) { @stats.specialteams_xpmissed }
			node (:xpblocked) { @stats.specialteams_xpblocked }
			node (:koreturn) { @stats.specialteams_koreturns }
			node (:kotd) { @stats.specialteams_kotd }
			node (:koyards) { @stats.specialteams_koyards }
			node (:kolong) { @stats.specialteams_kolong }
			node (:koattempts) { @stats.specialteams_koattempts }
			node (:kotouchbacks) { @stats.specialteams_kotouchbacks }
			node (:koreturned) { @stats.specialteams_koreturned }
			node (:punt_return) { @stats.specialteams_punt_return }
			node (:punt_returnyards) { @stats.specialteams_punt_returnyards }
			node (:punt_returntd) { @stats.specialteams_punt_returntd }
			node (:punt_returnlong) { @stats.specialteams_punt_returnlong }
		end
	end
end