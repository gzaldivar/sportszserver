if !@passing.nil?
	node (:attempts) { @passing.passing_attempts }
	node (:completions) { @passing.passing_completions }
	node (:comp_percentage) { @passing.passing_comp_percentage }
	node (:yards) { @passing.passing_yards }
	node (:tds) { @passing.passing_tds }
	node (:int) { @passing.passing_int }
	node (:sacks) { @passing.passing_sacks }
	node (:yards_lost) { @passing.passing_yards_lost }
end