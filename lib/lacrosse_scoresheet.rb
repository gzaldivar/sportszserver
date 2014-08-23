module LacrosseScoresheet

	def lacrossescoresheet
		@players = @sport.athletes.where(team_id: @gameschedule.team_id).asc(:number)
		@homescores = []
		@homepenalties = []

		@homeplayerstats_period1 = []
		@homeplayerstats_period2 = []
		@homeplayerstats_period3 = []
		@homeplayerstats_period4 = []
		@homeplayerstats_overtime = []

		@goalstats_period1 = []
		@goalstats_period2 = []
		@goalstats_period3 = []
		@goalstats_period4 = []
		@goalstats_overtime = []

		if @gameschedule.lacross_game.lacrosstats.any?

			@gameschedule.lacross_game.lacrosstats.each do |l|
				l.lacross_scorings.asc(:period).desc(:gametime).each do |stat|
					@homescores << stat
				end

				l.lacross_penalties.asc(:period).desc(:gametime).each do |penalty|
					@homepenalties << penalty
				end

				l.lacross_player_stats.asc(:period).each do |stats|
					if stats.period == 1
						@homeplayerstats_period1 << stats
					elsif stats.period == 2
						@homeplayerstats_period2 << stats
					elsif stats.period == 3
						@homeplayerstats_period3 << stats
					elsif stats.period == 4
						@homeplayerstats_period4 << stats
					else
						@homeplayerstats_overtime << stats
					end
				end

				l.lacross_goalstats.asc(:period).each do |stats|
					if stats.period == 1
						@goalstats_period1 << stats
					elsif stats.period == 2
						@goalstats_period2 << stats
					elsif stats.period == 3
						@goalstats_period3 << stats
					elsif stats.period == 4
						@goalstats_period4 << stats
					else
						@goalstats_overtime << stats
					end
				end
			end

		end

		@visitorscores = []
		@visitorpenalties = []

		@visitorplayerstats_period1 = []
		@visitorplayerstats_period2 = []
		@visitorplayerstats_period3 = []
		@visitorplayerstats_period4 = []
		@visitorplayerstats_overtime = []

		@visitor_goalstats_period1 = []
		@visitor_goalstats_period2 = []
		@visitor_goalstats_period3 = []
		@visitor_goalstats_period4 = []
		@visitor_goalstats_overtime = []

		if @gameschedule.lacross_game.visiting_team
			@visiting_roster = @gameschedule.lacross_game.visiting_team.visitor_rosters.all.asc(:number)

			@visiting_roster.each do |v|
				if v.lacrosstat and v.lacrosstat.lacross_scorings.any?
					v.lacrosstat.lacross_scorings.asc(:period).desc(:gametime).each do |score|
						@visitorscores << score
					end
				end

				if v.lacrosstat and v.lacrosstat.lacross_penalties.any?
					v.lacrosstat.lacross_penalties.asc(:period).desc(:gametime).each do |penalty|
						@visitorpenalties << penalty
					end
				end

				if v.lacrosstat and v.lacrosstat.lacross_player_stats.any?
					v.lacrosstat.lacross_player_stats.asc(:period).each do |stats|
						if stats.period == 1
							@visitorplayerstats_period1 << stats
						elsif stats.period == 2
							@visitorplayerstats_period2 << stats
						elsif stats.period == 3
							@visitorplayerstats_period3 << stats
						elsif stats.perios == 4
							@visitorplayerstats_period4 << stats
						else
							@visitorplayerstats_overtime << stats
						end
					end
				end

				if v.lacrosstat and v.lacrosstat.lacross_goalstats.any?
					v.lacross_goalstats.asc(:period).each do |stats|
						if stats.period == 1
							@visitor_goalstats_period1 << stats
						elsif stats.period == 2
							@visitor_goalstats_period2 << stats
						elsif stats.period == 3
							@visitor_goalstats_period3 << stats
						elsif stats.period == 4
							@visitor_goalstats_period4 << stats
						else
							@visitor_goalstats_overtime << stats
						end
					end
				end
			end

			@visitorscores.sort!{ |a, b| (a.period == b.period) ? a.gametime <=> b.gametime : a.period <=> b.period }
		end

		respond_to do |format|
			format.html { render 'gameschedules/lacrosse/scoresheet' }
			format.json
		end
	end

	def lacrosstimeout
		begin
			if params[:home] == lacrosse_home_team
				@gameschedule.lacross_game.home_1stperiod_timeouts[0] = gettimeentry(params[:firsttimeout_minutes1], params[:firsttimeout_seconds1]) 
				@gameschedule.lacross_game.home_2ndperiod_timeouts[0] = gettimeentry( params[:secondtimeout_minutes1], params[:secondtimeout_seconds1])
				@gameschedule.lacross_game.home_1stperiod_timeouts[1] = gettimeentry(params[:firsttimeout_minutes2], params[:firsttimeout_seconds2])
				@gameschedule.lacross_game.home_2ndperiod_timeouts[1] = gettimeentry(params[:secondtimeout_minutes2], params[:secondtimeout_seconds2])
				@gameschedule.lacross_game.home_1stperiod_timeouts[2] = gettimeentry(params[:firsttimeout_minutes3], params[:firsttimeout_seconds3])
				@gameschedule.lacross_game.home_2ndperiod_timeouts[2] = gettimeentry(params[:secondtimeout_minutes3], params[:secondtimeout_seconds3])
			else
				@gameschedule.lacross_game.visitor_1stperiod_timeouts[0] = gettimeentry(params[:firsttimeout_minutes1], params[:firsttimeout_seconds1]) 
				@gameschedule.lacross_game.visitor_2ndperiod_timeouts[0] = gettimeentry( params[:secondtimeout_minutes1], params[:secondtimeout_seconds1])
				@gameschedule.lacross_game.visitor_1stperiod_timeouts[1] = gettimeentry(params[:firsttimeout_minutes2], params[:firsttimeout_seconds2])
				@gameschedule.lacross_game.visitor_2ndperiod_timeouts[1] = gettimeentry(params[:secondtimeout_minutes2], params[:secondtimeout_seconds2])
				@gameschedule.lacross_game.visitor_1stperiod_timeouts[2] = gettimeentry(params[:firsttimeout_minutes3], params[:firsttimeout_seconds3])
				@gameschedule.lacross_game.visitor_2ndperiod_timeouts[2] = gettimeentry(params[:secondtimeout_minutes3], params[:secondtimeout_seconds3])
			end

			@gameschedule.lacross_game.save!

			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Time outs updated!" }
				format.json { render status: 200, json: { lacross_game: @gameschedule.lacross_game } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def lacrosse_extra_man
		begin
			if params[:home] == lacrosse_home_team
				@gameschedule.lacross_game.extraman_fail[0] = params[:xman1].to_i
				@gameschedule.lacross_game.extraman_fail[1] = params[:xman2].to_i
				@gameschedule.lacross_game.extraman_fail[2] = params[:xman3].to_i
				@gameschedule.lacross_game.extraman_fail[3] = params[:xman4].to_i
				@gameschedule.lacross_game.extraman_fail[4] = params[:xman5].to_i
			else
				if @gameschedule.lacross_game.visiting_team
					if @gameschedule.lacross_game.visitor_extraman_fail.empty?
						@gameschedule.lacross_game.visitor_extraman_fail = Array.new(5) { 0 } 
					end

					@gameschedule.lacross_game.visitor_extraman_fail[0] = params[:xman1].to_i
					@gameschedule.lacross_game.visitor_extraman_fail[1] = params[:xman2].to_i
					@gameschedule.lacross_game.visitor_extraman_fail[2] = params[:xman3].to_i
					@gameschedule.lacross_game.visitor_extraman_fail[3] = params[:xman4].to_i					
					@gameschedule.lacross_game.visitor_extraman_fail[4] = params[:xman5].to_i					
				else
					raise 'No visiting assigned to this game.'
				end
			end

			@gameschedule.save!

			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: 'Stats updated!' }
				format.json { render status: 200, json: { lacross_game: @gameschedule.lacross_game } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def lacrosse_clears
		begin
			if params[:home] == lacrosse_home_team
				@gameschedule.lacross_game.clears[0] = params[:clear1].to_i
				@gameschedule.lacross_game.clears[1] = params[:clear2].to_i
				@gameschedule.lacross_game.clears[2] = params[:clear3].to_i
				@gameschedule.lacross_game.clears[3] = params[:clear4].to_i
				@gameschedule.lacross_game.clears[4] = params[:clear5].to_i

				@gameschedule.lacross_game.failedclears[0] = params[:failedclear1].to_i
				@gameschedule.lacross_game.failedclears[1] = params[:failedclear2].to_i
				@gameschedule.lacross_game.failedclears[2] = params[:failedclear3].to_i
				@gameschedule.lacross_game.failedclears[3] = params[:failedclear4].to_i
				@gameschedule.lacross_game.failedclears[4] = params[:failedclear5].to_i
			else
				if @gameschedule.lacross_game.visiting_team
					if @gameschedule.lacross_game.visitor_clears.empty?
						@gameschedule.lacross_game.visitor_clears = Array.new(5) { 0 } 
						@gameschedule.lacross_game.visitor_failedclears = Array.new(5) { 0 }
					end

					@gameschedule.lacross_game.visitor_clears[0] = params[:clear1].to_i
					@gameschedule.lacross_game.visitor_clears[1] = params[:clear2].to_i
					@gameschedule.lacross_game.visitor_clears[2] = params[:clear3].to_i
					@gameschedule.lacross_game.visitor_clears[3] = params[:clear4].to_i
					@gameschedule.lacross_game.visitor_clears[4] = params[:clear5].to_i

					@gameschedule.lacross_game.visitor_failedclears[0] = params[:failedclear1].to_i
					@gameschedule.lacross_game.visitor_failedclears[1] = params[:failedclear2].to_i
					@gameschedule.lacross_game.visitor_failedclears[2] = params[:failedclear3].to_i
					@gameschedule.lacross_game.visitor_failedclears[3] = params[:failedclear4].to_i
					@gameschedule.lacross_game.visitor_failedclears[4] = params[:failedclear5].to_i
				end
			end

			@gameschedule.save!

			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: 'Stats updated!' }
				format.json { render status: 200, json: { lacross_game: @gameschedule.lacross_game } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def lacrosse_game_summary
		begin
			@lacrossgame = @gameschedule.lacross_game

			render 'gameschedules/lacrosse/lacrosse_game_summary'
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def update_lacrosse_game_summary
		begin
			@gameschedule.lacross_game.home_penaltyone_number = params[:homeonenumber].to_i
			@gameschedule.lacross_game.home_penaltyone_minutes = params[:homeoneminutes].to_i
			@gameschedule.lacross_game.home_penaltyone_seconds = params[:homeoneseconds].to_i
			@gameschedule.lacross_game.home_penaltytwo_number = params[:hometwonumber].to_i
			@gameschedule.lacross_game.home_penaltytwo_minutes = params[:hometwominutes].to_i
			@gameschedule.lacross_game.home_penaltytwo_seconds = params[:hometwoseconds].to_i
			@gameschedule.lacross_game.visitor_penaltyone_number = params[:visitoronenumber].to_i
			@gameschedule.lacross_game.visitor_penaltyone_minutes = params[:visitoroneminutes].to_i
			@gameschedule.lacross_game.visitor_penaltyone_seconds = params[:visitoroneseconds].to_i
			@gameschedule.lacross_game.visitor_penaltytwo_number = params[:visitortwonumber].to_i
			@gameschedule.lacross_game.visitor_penaltytwo_minutes = params[:visitortwominutes].to_i
			@gameschedule.lacross_game.visitor_penaltytwo_seconds = params[:visitortwoseconds].to_i

			@gameschedule.lacross_game.visitor_score_period1 = params[:visitor_score_period1].to_i
			@gameschedule.lacross_game.visitor_score_period2 = params[:visitor_score_period2].to_i
			@gameschedule.lacross_game.visitor_score_period3 = params[:visitor_score_period3].to_i
			@gameschedule.lacross_game.visitor_score_period4 = params[:visitor_score_period4].to_i
			@gameschedule.lacross_game.visitor_score_periodOT1 = params[:visitor_score_periodOT1].to_i

			@gameschedule.save!
			@gameschedule.lacross_game.save!

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: 'Game Updated!' }
				format.json { render status: 200, json: { lacross_game: @gameschedule.lacross_game } }
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end		
	end

	def lacrosse_score_entry
		begin
			index = params[:index].to_i
			gametime = params[:minutes] + ':' + params[:seconds]

			if !params[:player].blank?
				if params[:home] == lacrosse_home_team
					if params[:lacross_scoring_id]
						lacrosstat = @gameschedule.lacross_game.lacrosstats.find(params[:lacrosstat_id])
						score = lacrosstat.lacross_scorings.find(params[:lacross_scoring_id])
						score.gametime = gametime
						score.period = params[:period]
						score.scorecode = params[:scorecode]
					else
						lacrosstat = @gameschedule.lacross_game.lacrosstats.find_by(athlete_id: params[:player])

						if lacrosstat.nil?
							lacrosstat = @gameschedule.lacross_game.lacrosstats.new
							lacrosstat.athlete_id = params[:player]
							lacrosstat.save!
						end

						score = lacrosstat.lacross_scorings.new(gametime: gametime, scorecode: params[:scorecode], period: params[:period])
					end

					playerstat = lacrosstat.lacross_player_stats.find_by(period: params[:period])

					if playerstat.nil?
						playerstat = lacrosstat.lacross_player_stats.new(period: params[:period])
					end

					playerstat.shot << lacrosse_shot_goal
					playerstat.save!

					if !params[:assist].blank?
						score.assist = params[:assist]
					end

					score.save!
				elsif @gameschedule.lacross_game.visiting_team
					visitingplayer = @gameschedule.lacross_game.visiting_team.visitor_rosters.find(params[:player])

					if params[:lacross_scoring_id]
						lacrosstat = visiting_player.lacrosstats.find(params[:lacrosstat_id])
						score = lacrosstat.lacross_scorings.find(params[:lacross_scoring_id])
						score.gametime = gametime
						score.period = params[:period]
						score.scorecode = params[:scorecode]
					elsif visitingplayer.lacrosstat
						score = visitingplayer.lacrosstat.lacross_scorings.new(gametime: gametime, scorecode: params[:scorecode], period: params[:period])
						lacrosstat = visitingplayer.lacrosstat
					else
						lacrosstat = Lacrosstat.new(visitor_roster: visitingplayer.id, lacross_game: @gameschedule.lacross_game.id)
						lacrosstat.save!

						score = lacrosstat.lacross_scorings.new(gametime: gametime, scorecode: params[:scorecode], period: params[:period])
					end

					playerstat = lacrosstat.lacross_player_stats.find_by(period: params[:period])

					if playerstat.nil?
						playerstat = lacrosstat.lacross_player_stats.new(period: params[:period])
					end

					playerstat.shot << lacrosse_shot_goal
					playerstat.save!

					if !params[:assist].blank?
						score.assist = params[:assist]
					end

					score.save!
				end

				respond_to do |format|
					format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Stat Updated!" }
					format.json { render status: 200, json: { lacross_scoring: score } }
				end
			else
				raise 'Error - Player and valid score time required!'
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def lacrosse_add_penalty
		begin
			gametime = params[:minutes] + ':' + params[:seconds]

			if !params[:player].blank? and gametime =~ /^\d{1,2}:\d{1,2}/ 

				if !params[:personal].blank? and !params[:technical].blank?
					raise 'Only a personal foul or technical foul may be selected'
				end

				if params[:personal].blank? and params[:technical].blank?
					raise 'A personal foul or technical foul is required'
				end

				if params[:home] == lacrosse_home_team
					if params[:lacross_penalty_id]
						lacrosstat = @gameschedule.lacross_game.lacrosstats.find(params[:lacrosstat_id])
						penalty = lacrosstat.lacross_penalties.find(params[:lacross_penalty_id])
						penalty.gametime = gametime
						penalty.period = params[:period]
					else
						lacrosstat = @gameschedule.lacross_game.lacrosstats.find_by(athlete_id: params[:player])

						if lacrosstat.nil?
							lacrosstat = @gameschedule.lacross_game.lacrosstats.new
							lacrosstat.athlete_id = params[:player]
							lacrosstat.save!
						end

						penalty = lacrosstat.lacross_penalties.new(gametime: gametime, period: params[:period])
					end

					if !params[:personal].blank?
						penalty.type = 'P'
						penalty.infraction = params[:personal]
					else
						penalty.type = 'T'
						penalty.infraction = params[:technical]
					end

					penalty.save!
				elsif @gameschedule.lacross_game.visiting_team
					visitingplayer = @gameschedule.lacross_game.visiting_team.visitor_rosters.find(params[:player])

					if params[:lacross_penalty_id]
						lacrosstat = visiting_player.lacrosstats.find(params[:lacrosstat_id])
						penalty = lacrosstat.lacross_penalties.find(params[:lacross_penalty_id])
						penalty.gametime = gametime
						penalty.period = params[:period]
					elsif visitingplayer.lacrosstat
						penalty = visitingplayer.lacrosstat.lacross_penalties.new(gametime: gametime, period: params[:period])

					else
						lacrosstat = Lacrosstat.new(visitor_roster: visitingplayer.id, lacross_game: @gameschedule.lacross_game.id)
						lacrosstat.save!

						penalty = lacrosstat.lacross_penalties.new(gametime: gametime, period: params[:period])
					end

					if !params[:personal].blank?
						penalty.type = 'P'
						penalty.infraction = params[:personal]
					else
						penalty.type = 'T'
						penalty.infraction = params[:technical]
					end

					penalty.save!
				end

				respond_to do |format|
					format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Stat Updated!" }
					format.json { render status: 200, json: { lacross_penalty: penalty } }
				end
			else
				raise 'Player and Time of Penalty required'
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def lacrosse_add_shot		
		begin
			if !params[:player].blank? and !params[:addshot].blank? and params[:addshot] != lacrosse_shot_goal

				if params[:home] == lacrosse_home_team
					playerstat = homeplayerstat
				elsif @gameschedule.lacross_game.visiting_team
					playerstat = visitorplayerstat
				end
				
				playerstat.shot << params[:addshot]
				playerstat.save!

				respond_to do |format|
					format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Shot Added!" }
					format.json { render status: 200, json: { playerstats: playerstat } }
				end
			elsif params[:addshot] == lacrosse_shot_goal
				raise 'Shot as goal is automatically entered when goal is recorded. No need to do it here.'
			else
				raise 'Player and shot must be selected'
			end
			
		rescue Exception => e
			respond_to do |format|
				format.html {redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end		
	end

	def lacrosse_player_stats
		begin
			if params[:player].blank? and params[:lacross_player_stat_id].blank?
				raise 'Player must be entered'
			end
				
			if params[:home] == lacrosse_home_team
				playerstat = homeplayerstat
			elsif @gameschedule.lacross_game.visiting_team
				playerstat = visitorplayerstat
			end

			if !params[:steals].blank?
				playerstat.steals = params[:steals].to_i
			end

			if !params[:groundball].blank?
				playerstat.ground_ball = params[:groundball].to_i
			end

			if !params[:face_off_won].blank?
				playerstat.face_off_won = params[:face_off_won].to_i
			end

			if !params[:face_off_lost].blank?
				playerstat.face_off_lost = params[:face_off_lost].to_i
			end

			if !params[:violation].blank?
				playerstat.face_off_violation = params[:violation].to_i
			end

			if !params[:turnovers].blank?
				playerstat.turnover = params[:turnovers].to_i
			end

			playerstat.save!

			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Player Stats Updated!" }
				format.json { render status: 200, json: { playerstats: playerstat } }
			end
			
		rescue Exception => e
			respond_to do |format|
				format.html {redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end		
	end

	def lacrosse_goalstats
		begin
			if params[:player].blank? and params[:lacross_goalstat_id].blank?
				raise 'Player must be entered'
			end
				
			if params[:lacross_goalstat_id]
				lacrosstat = @gameschedule.lacross_game.lacrosstats.find(params[:lacrosstat_id])
				playerstat = lacrosstat.lacross_goalstats.find(params[:lacross_goalstat_id])
			else
				lacrosstat = @gameschedule.lacross_game.lacrosstats.find_by(athlete_id: params[:player])

				if lacrosstat.nil?
					lacrosstat = @gameschedule.lacross_game.lacrosstats.new
					lacrosstat.athlete_id = params[:player]
					lacrosstat.save!
					playerstat = lacrosstat.lacross_goalstats.new(period: params[:period])
				elsif lacrosstat.lacross_goalstats.where(period: params[:period]).count > 0
					playerstat = lacrosstat.lacross_goalstats.find_by(period: params[:period])
				else
					playerstat = lacrosstat.lacross_goalstats.new(period: params[:period])
				end

			end

			playerstat.saves = params[:saves].to_i
			playerstat.minutesplayed = params[:minutesplayed].to_i
			playerstat.goals_allowed = params[:goals_allowed].to_i
			playerstat.save!

			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: 'Goalie Stats Updated' }
				format.json { render status: 200, json: { lacross_goalstat: playerstat } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { eror: e.message } }
			end
		end
	end

	def delete_visiting_score
		lacrosstat = Lacrosstat.find(params[:lacrosstat_id]).lacross_scorings.find(params[:lacross_scoring_id]).destroy

		respond_to do |format|
			format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Visitor score deleted!" }
			format.json { render status: 200, json: { success: "Success" } }
		end
	end

	def delete_visiting_penalty
		lacrosstat = Lacrosstat.find(params[:lacrosstat_id]).lacross_penalties.find(params[:lacross_penalty_id]).destroy

		respond_to do |format|
			format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Visitor penalty deleted!" }
			format.json { render status: 200, json: { success: "Success" } }
		end
	end

	def remove_allshots
		begin
			stat = Lacrosstat.find(params[:lacrosstat_id]).lacross_player_stats.find(params[:lacross_player_stat_id])
			stat.shot = []
			stat.save!
			
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "All shots deleted for player!" }
				format.json { render status: 200, json: { success: "success" } }
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end		
	end

	def delete_lacrosse_player_shot
		playerstat = Lacrosstat.find(params[:lacrosstat_id]).lacross_player_stats.find(params[:lacross_player_stat_id])

		if playerstat.shot.count > 0
			cnt = 0

			playerstat.shot.each do |p|
				if p == params[:shot]
					break
				else
					cnt += 1
				end
			end

			playerstat.shot.delete_at(cnt)
			playerstat.save!
		end

		respond_to do |format|
			format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Shot deleted!" }
			format.json { render status: 200, json: { lacross_game: @gameschedule.lacross_game } }
		end
	end

	def delete_visiting_player_stats
		lacrosstat = Lacrosstat.find(params[:lacrosstat_id]).lacross_player_stats.find(params[:lacross_player_stat_id]).destroy

		respond_to do |format|
			format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Visitor player stats deleted!" }
			format.json { render status: 200, json: { success: "Success" } }
		end
	end

	private

		def gettimeentry(minutes, seconds)
			if minutes.to_i == 0 and seconds.to_i == 0
				""
			else
				minutes + ':' + seconds
			end
		end

		def homeplayerstat
			if params[:lacross_player_stat_id]
				lacrosstat = @gameschedule.lacross_game.lacrosstats.find(params[:lacrosstat_id])
				playerstat = lacrosstat.lacross_player_stats.find(params[:lacross_player_stat_id])
			else
				lacrosstat = @gameschedule.lacross_game.lacrosstats.find_by(athlete_id: params[:player])

				if lacrosstat.nil?
					lacrosstat = @gameschedule.lacross_game.lacrosstats.new
					lacrosstat.athlete_id = params[:player]
					lacrosstat.save!
					playerstat = lacrosstat.lacross_player_stats.new(period: params[:period])
				elsif lacrosstat.lacross_player_stats.where(period: params[:period]).count > 0
					playerstat = lacrosstat.lacross_player_stats.find_by(period: params[:period])
				else
					playerstat = lacrosstat.lacross_player_stats.new(period: params[:period])
				end

			end

			return playerstat
		end

		def visitorplayerstat
			visitingplayer = @gameschedule.lacross_game.visiting_team.visitor_rosters.find(params[:player])

			if params[:lacross_player_stat_id]
				lacrosstat = visiting_player.lacrosstats.find(params[:lacrosstat_id])
				playerstat = lacrosstat.lacross_player_stats.find(params[:lacross_player_stat_id])
			elsif visitingplayer.lacrosstat
				if visitingplayer.lacrosstat.lacross_player_stats.nil?
					playerstat = visitingplayer.lacrosstat.lacross_player_stats.new(period: params[:period])
				elsif visitingplayer.lacrosstat.lacross_player_stats.where(period: params[:period]).count > 0
					playerstat = visitingplayer.lacrosstat.lacross_player_stats.find_by(period: params[:period])
				else
					playerstat = visitingplayer.lacrosstat.lacross_player_stats.new(period: params[:period])
				end
			else
				lacrosstat = Lacrosstat.new(visitor_roster: visitingplayer.id, lacross_game: @gameschedule.lacross_game.id)
				lacrosstat.save!
				playerstat = lacrosstat.lacross_player_stats.new(period: params[:period])
			end

			return playerstat
		end

end