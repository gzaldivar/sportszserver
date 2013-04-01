if !@defense.nil?
	node (:tackles) { @defense.defense_tackles }
	node (:assists) { @defense.defense_assists }
	node (:sacks) { @defense.defense_sacks }
	node (:pass_defended) { @defense.defense_pass_defended }
	node (:interceptions) { @defense.defense_interceptions }
	node (:int_yards) { @defense.defense_int_yards }
	node (:int_long) { @defense.defense_int_long }
	node (:int_td) { @defense.defense_int_td }
	node (:fumbles_recovered) { @defense.defense_fumbles_recovered }
end