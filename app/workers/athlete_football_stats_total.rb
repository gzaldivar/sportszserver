class AthleteFootballStatsTotal
	attr_accessor :passing_attempts, :passing_completions, :passing_comp_percentage, :passing_yards, 
				  :passing_tds, :passing_int, :passing_sacks, :passing_yards_lost, :passing_firstdowns,
				  :rushing_attempts, :rushing_longest, :rushing_yards, :rushing_tds, :rushing_fumbles, 
				  :rushing_fumbles_lost, :rushing_average, :rushing_firstdowns,
				  :receiving_receptions, :receiving_longest, :receiving_yards, :receiving_tds,
				  :receiving_fumbles, :receiving_fumbles_lost, :receiving_average,
				  :defense_tackles, :defense_assists, :defense_sacks, :defense_pass_defended, :defense_interceptions,
				  :defense_int_yards,:defense_int_long, :defense_int_td, :defense_fumbles_recovered,
				  :kickers_fgattempts, :kickers_fgmade, :kickers_fgblocked, :kickers_fglong,
				:kickers_xpattempts, :kickers_xpmade, :kickers_xpmissed, :kickers_xpblocked, :kickers_punts,
				:kickers_punts_blocked, :kickers_punts_yards, :kickers_punts_long, :kickers_koattempts,
				:kickers_kotouchbacks, :kickers_koreturned, :kickers_koreturn_average, :returners_punt_return,
				:returners_punt_returntd, :returners_punt_returnyards, :returners_punt_returnlong, :returners_koreturns,
				:returners_kotd, :returners_kolong, :returners_koyards, :passing_twopointconv, :rushing_twopointconv,
				:receiving_twopointconv, :defense_safety

	def passing_totals(athlete)
		self.passing_attempts = 0
		self.passing_completions = 0
		self.passing_comp_percentage = 0
		self.passing_yards = 0
		self.passing_tds = 0
		self.passing_int = 0
		self.passing_sacks = 0
		self.passing_yards_lost = 0
		self.passing_twopointconv = 0
		self.passing_firstdowns = 0

		athlete.football_stats.each do |s|
			if !s.football_passings.nil?
				self.passing_attempts = self.passing_attempts + s.football_passings.attempts
				self.passing_completions = self.passing_completions + s.football_passings.completions
				self.passing_yards = self.passing_yards + s.football_passings.yards
				self.passing_tds = self.passing_tds + s.football_passings.td
				self.passing_int = self.passing_int + s.football_passings.interceptions
				self.passing_sacks = self.passing_sacks + s.football_passings.sacks
				self.passing_yards_lost = self.passing_yards_lost + s.football_passings.yards_lost
				self.passing_twopointconv = self.passing_twopointconv + s.football_passings.twopointconv
				self.passing_firstdowns = self.passing_firstdowns + s.football_passings.firstdowns
			end
		end
		if self.passing_attempts != 0
			self.passing_comp_percentage = Float(self.passing_completions) / Float(self.passing_attempts)
		else
			self.passing_comp_percentage = 0.0
		end
	end

	def rushing_totals(athlete)
		self.rushing_attempts = 0
		self.rushing_longest = 0
		self.rushing_yards = 0
		self.rushing_tds = 0
		self.rushing_fumbles = 0
		self.rushing_fumbles_lost = 0
		self.rushing_average = 0.0
		self.rushing_twopointconv = 0
		self.rushing_firstdowns = 0

		athlete.football_stats.each do |s|
			if !s.football_rushings.nil?
				self.rushing_attempts = self.rushing_attempts + s.football_rushings.attempts
				self.rushing_yards = self.rushing_yards + s.football_rushings.yards
				self.rushing_tds = self.rushing_tds + s.football_rushings.td
				self.rushing_fumbles = self.rushing_fumbles + s.football_rushings.fumbles
				self.rushing_fumbles_lost = self.rushing_fumbles_lost + s.football_rushings.fumbles_lost
				if self.rushing_longest < s.football_rushings.longest
					self.rushing_longest = s.football_rushings.longest
				end
				self.rushing_twopointconv = self.rushing_twopointconv + s.football_rushings.twopointconv
				self.rushing_firstdowns = self.rushing_firstdowns + s.football_rushings.firstdowns
			end
		end
		if self.rushing_attempts != 0 and self.rushing_yards != 0
			self.rushing_average = Float(self.rushing_yards) / Float(self.rushing_attempts)
		else
			self.rushing_average = 0.0
		end
	end

	def receiving_totals(athlete)
		self.receiving_receptions = 0
		self.receiving_longest = 0
		self.receiving_yards = 0
		self.receiving_tds = 0
		self.receiving_fumbles = 0
		self.receiving_fumbles_lost = 0
		self.receiving_average = 0.0
		self.receiving_twopointconv = 0

		athlete.football_stats.each do |s|
			if !s.football_receivings.nil?
				self.receiving_receptions = self.receiving_receptions + s.football_receivings.receptions
				self.receiving_yards = self.receiving_yards + s.football_receivings.yards
				self.receiving_tds = self.receiving_tds + s.football_receivings.td
				self.receiving_fumbles = self.receiving_fumbles + s.football_receivings.fumbles
				self.receiving_fumbles_lost = self.receiving_fumbles_lost + s.football_receivings.fumbles_lost
				if self.receiving_longest < s.football_receivings.longest
					self.receiving_longest = s.football_receivings.longest
				end
				self.receiving_twopointconv = self.receiving_twopointconv + s.football_receivings.twopointconv
			end
		end
		if self.receiving_receptions != 0 and self.receiving_yards != 0
			self.receiving_average = Float(self.receiving_yards) / Float(self.receiving_receptions)
		else
			self.receiving_average = 0.0
		end
	end

	def defense_totals(athlete)
		self.defense_tackles = 0
		self.defense_assists = 0
		self.defense_sacks = 0
		self.defense_pass_defended = 0
		self.defense_interceptions = 0
		self.defense_int_yards = 0
		self.defense_int_long = 0
		self.defense_int_td = 0
		self.defense_fumbles_recovered = 0
		self.defense_safety = 0

		athlete.football_stats.each do |s|
			if !s.football_defenses.nil?
				self.defense_tackles = self.defense_tackles + s.football_defenses.tackles
				self.defense_assists = self.defense_assists + s.football_defenses.assists
				self.defense_sacks = self.defense_sacks + s.football_defenses.sacks
				self.defense_pass_defended = self.defense_pass_defended + s.football_defenses.pass_defended
				self.defense_interceptions = self.defense_interceptions + s.football_defenses.interceptions
				self.defense_int_yards = self.defense_int_yards + s.football_defenses.int_yards
				self.defense_fumbles_recovered = self.defense_fumbles_recovered + s.football_defenses.fumbles_recovered
				self.defense_int_td = self.defense_int_td + s.football_defenses.int_td
				if self.defense_int_long < s.football_defenses.int_long
					self.defense_int_long = s.football_defenses.int_long
				end
				self.defense_safety = self.defense_safety + s.football_defenses.safety
			end
		end
	end

	def specialteams_totals(athlete)		
		self.kickers_fgattempts = 0
		self.kickers_fgmade = 0
		self.kickers_fgblocked = 0
		self.kickers_fglong = 0

		self.kickers_xpattempts = 0
		self.kickers_xpmade = 0
		self.kickers_xpmissed = 0
		self.kickers_xpblocked = 0

		self.kickers_koattempts = 0
		self.kickers_kotouchbacks = 0
		self.kickers_koreturned = 0
		self.kickers_koreturn_average = 0.0

		self.kickers_punts = 0
		self.kickers_punts_blocked = 0
		self.kickers_punts_yards = 0
		self.kickers_punts_long = 0

		self.returners_punt_return = 0
		self.returners_punt_returntd = 0
		self.returners_punt_returnyards = 0
		self.returners_punt_returnlong = 0

		self.returners_koreturns = 0
		self.returners_kotd = 0
		self.returners_kolong = 0
		self.returners_koyards = 0

		athlete.football_stats.each do |s|
			if !s.football_kickers.nil?

				if !s.football_kickers.fgattempts.nil?
					self.kickers_fgattempts = self.kickers_fgattempts + s.football_kickers.fgattempts
					self.kickers_fgmade = self.kickers_fgmade + s.football_kickers.fgmade
					self.kickers_fgblocked = self.kickers_fgblocked + s.football_kickers.fgblocked

					self.kickers_xpattempts = self.kickers_xpattempts + s.football_kickers.xpattempts
					self.kickers_xpmade = self.kickers_xpmade + s.football_kickers.xpmade
					self.kickers_xpmissed = self.kickers_xpmissed + s.football_kickers.xpmissed
					self.kickers_xpblocked = self.kickers_xpblocked + s.football_kickers.xpblocked

					if self.kickers_fglong < s.football_kickers.fglong
						self.kickers_fglong = s.football_kickers.fglong
					end
				end

				if !s.football_kickers.koattempts.nil?
					self.kickers_koattempts = self.kickers_koattempts + s.football_kickers.koattempts
					self.kickers_kotouchbacks = self.kickers_kotouchbacks + s.football_kickers.kotouchbacks
					self.kickers_koreturned = self.kickers_koreturned + s.football_kickers.koreturned
#					self.kickers_koreturn_average = self.kickers_koreturn_average + s.football_kickers.koreturn_average
				end

				if !s.football_kickers.punts.nil?
					self.kickers_punts = self.kickers_punts + s.football_kickers.punts
					self.kickers_punts_blocked = self.kickers_punts_blocked + s.football_kickers.punts_blocked
					self.kickers_punts_yards = self.kickers_punts_yards + s.football_kickers.punts_yards
					if self.kickers_punts_long < s.football_kickers.punts_long
						self.kickers_punts_long = s.football_kickers.punts_long
					end
				end
			end
			if !s.football_returners.nil?
				if !s.football_returners.punt_return.nil?
					self.returners_punt_return = self.returners_punt_return + s.football_returners.punt_return
					self.returners_punt_returntd = self.returners_punt_returntd + s.football_returners.punt_returntd
					self.returners_punt_returnyards = self.returners_punt_returnyards + s.football_returners.punt_returnyards
					if self.returners_punt_returnlong < s.football_returners.punt_returnlong
						self.returners_punt_returnlong = s.football_returners.punt_returnlong
					end
				end

				if !s.football_returners.koreturns.nil?
					self.returners_koreturns = self.returners_koreturns + s.football_returners.koreturns
					self.returners_kotd = self.returners_kotd + s.football_returners.kotd
					self.returners_koyards = self.returners_koyards + s.football_returners.koyards
					if self.returners_kolong < s.football_returners.kolong
						self.returners_kolong = s.football_returners.kolong
					end
				end
			end
		end
	end
end