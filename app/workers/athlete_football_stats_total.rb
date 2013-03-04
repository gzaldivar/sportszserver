class AthleteFootballStatsTotal
	attr_accessor :passing_attempts, :passing_completions, :passing_comp_percentage, :passing_yards, 
				  :passing_tds, :passing_int, :passing_sacks, :passing_yards_lost, 
				  :rushing_attempts, :rushing_longest, :rushing_yards, :rushing_tds, :rushing_fumbles, 
				  :rushing_fumbles_lost, :rushing_average,
				  :receiving_receptions, :receiving_longest, :receiving_yards, :receiving_tds,
				  :receiving_fumbles, :receiving_fumbles_lost, :receiving_average,
				  :defense_tackles, :defense_assists, :defense_sacks, :defense_pass_defended, :defense_interceptions,
				  :defense_int_yards,:defense_int_long, :defense_int_td, :defense_fumbles_recovered,
				  :specialteams_fgattempts, :specialteams_fgmade, :specialteams_fgblocked, :specialteams_fglong,
				:specialteams_xpattempts, :specialteams_xpmade, :specialteams_xpmissed, :specialteams_xpblocked, :specialteams_koattempts,
				:specialteams_kotouchbacks, :specialteams_koreturned, :specialteams_koreturn_average, :specialteams_punts,
				:specialteams_punts_blocked, :specialteams_punts_yards, :specialteams_punts_long, :specialteams_punt_return,
				:specialteams_punt_returntd, :specialteams_punt_returnyards, :specialteams_punt_returnlong, :specialteams_koreturns,
				:specialteams_kotd, :specialteams_kolong, :specialteams_koyards

	def passing_totals(athlete)
		self.passing_attempts = 0
		self.passing_completions = 0
		self.passing_comp_percentage = 0
		self.passing_yards = 0
		self.passing_tds = 0
		self.passing_int = 0
		self.passing_sacks = 0
		self.passing_yards_lost = 0

		athlete.football_stats.each do |s|
			if !s.football_passings.nil?
				self.passing_attempts = self.passing_attempts + s.football_passings.attempts
				self.passing_completions = self.passing_completions + s.football_passings.completions
				self.passing_yards = self.passing_yards + s.football_passings.yards
				self.passing_tds = self.passing_tds + s.football_passings.td
				self.passing_int = self.passing_int + s.football_passings.interceptions
				self.passing_sacks = self.passing_sacks + s.football_passings.sacks
				self.passing_yards_lost = self.passing_yards_lost + s.football_passings.yards_lost
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
			end
		end
	end

	def specialteams_totals(athlete)		
		self.specialteams_fgattempts = 0
		self.specialteams_fgmade = 0
		self.specialteams_fgblocked = 0
		self.specialteams_fglong = 0

		self.specialteams_xpattempts = 0
		self.specialteams_xpmade = 0
		self.specialteams_xpmissed = 0
		self.specialteams_xpblocked = 0

		self.specialteams_koattempts = 0
		self.specialteams_kotouchbacks = 0
		self.specialteams_koreturned = 0
		self.specialteams_koreturn_average = 0.0

		self.specialteams_punts = 0
		self.specialteams_punts_blocked = 0
		self.specialteams_punts_yards = 0
		self.specialteams_punts_long = 0

		self.specialteams_punt_return = 0
		self.specialteams_punt_returntd = 0
		self.specialteams_punt_returnyards = 0
		self.specialteams_punt_returnlong = 0

		self.specialteams_koreturns = 0
		self.specialteams_kotd = 0
		self.specialteams_kolong = 0
		self.specialteams_koyards = 0

		cnt = 0

		athlete.football_stats.each do |s|
			if !s.football_specialteams.nil?

				if !s.football_specialteams.fgattempts.nil?
					self.specialteams_fgattempts = self.specialteams_fgattempts + s.football_specialteams.fgattempts
					self.specialteams_fgmade = self.specialteams_fgmade + s.football_specialteams.fgmade
					self.specialteams_fgblocked = self.specialteams_fgblocked + s.football_specialteams.fgblocked

					self.specialteams_xpattempts = self.specialteams_xpattempts + s.football_specialteams.xpattempts
					self.specialteams_xpmade = self.specialteams_xpmade + s.football_specialteams.xpmade
					self.specialteams_xpmissed = self.specialteams_xpmissed + s.football_specialteams.xpmissed
					self.specialteams_xpblocked = self.specialteams_xpblocked + s.football_specialteams.xpblocked

					if self.specialteams_fglong < s.football_specialteams.fglong
						self.specialteams_fglong = s.football_specialteams.fglong
					end
				end

				if !s.football_specialteams.koattempts.nil?
					self.specialteams_koattempts = self.specialteams_koattempts + s.football_specialteams.koattempts
					self.specialteams_kotouchbacks = self.specialteams_kotouchbacks + s.football_specialteams.kotouchbacks
					self.specialteams_koreturned = self.specialteams_koreturned + s.football_specialteams.koreturned
#					self.specialteams_koreturn_average = self.specialteams_koreturn_average + s.football_specialteams.koreturn_average
				end

				if !s.football_specialteams.punts.nil?
					self.specialteams_punts = self.specialteams_punts + s.football_specialteams.punts
					self.specialteams_punts_blocked = self.specialteams_punts_blocked + s.football_specialteams.punts_blocked
					self.specialteams_punts_yards = self.specialteams_punts_yards + s.football_specialteams.punts_yards
					if self.specialteams_punts_long < s.football_specialteams.punts_long
						self.specialteams_punts_long = s.football_specialteams.punts_long
					end
				end

				if !s.football_specialteams.punt_return.nil?
					self.specialteams_punt_return = self.specialteams_punt_return + s.football_specialteams.punt_return
					self.specialteams_punt_returntd = self.specialteams_punt_returntd + s.football_specialteams.punt_returntd
					self.specialteams_punt_returnyards = self.specialteams_punt_returnyards + s.football_specialteams.punt_returnyards
					if self.specialteams_punt_returnlong < s.football_specialteams.punt_returnlong
						self.specialteams_punt_returnlong = s.football_specialteams.punt_returnlong
					end
				end

				if !s.football_specialteams.koreturns.nil?
					self.specialteams_koreturns = self.specialteams_koreturns + s.football_specialteams.koreturns
					self.specialteams_kotd = self.specialteams_kotd + s.football_specialteams.kotd
					self.specialteams_koyards = self.specialteams_koyards + s.football_specialteams.koyards
					if self.specialteams_kolong < s.football_specialteams.kolong
						self.specialteams_kolong = s.football_specialteams.kolong
					end
				end
				cnt += 1
			end
		end
#		self.specialteams_koreturn_average = self.specialteams_koreturn_average / cnt
	end
end