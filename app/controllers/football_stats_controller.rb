class FootballStatsController < ApplicationController
	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :showdata]
  	before_filter 	:get_sport_athlete
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		controller.team_manager?(@athlete, nil)
	end

	def newstat
		@stattype = params[:id]
		if @athlete.team != "Unassigned"
			@games = @sport.teams.find(@athlete.team_id).gameschedules.asc(:gamedate)
		else
			redirect_to :back, alert: "Athlete is unnassigned to a team. Stats must be associated with a game which can only be played by teams"
		end
		@stat = FootballStat.new
	end

	def create
		if !params[:game].nil? and !params[:game].blank?
			if !(@stat = @athlete.football_stats.where(gameschedule_id: params[:game].to_s).first)
				if !(@stat = @athlete.football_stats.create!(gameschedule_id: params[:game].to_s))
					redirect_to :back, error: "Error creating stat package for player " + @athlete.full_name 
				end
			end
		else
			redirect_to :back, error: "You must select a game to enter stats!"
		end

		case params[:football_stat][:stattype]
		when "passing"
			if @stat.football_passings.nil? and params[:stats] == "Game Totals"
				redirect_to new_sport_athlete_football_stat_football_passing_path(@sport, @athlete, @stat)
			elsif @stat.football_passings.nil? and params[:stats] == "Play by Play"
				@stat.create_football_passings
				respond_to do |format|
					format.html { redirect_to add_sport_athlete_football_stat_football_passing_path(@sport, @athlete, @stat, @stat.football_passings) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_passings.nil? and params[:stats] == "Game Totals"
				redirect_to edit_sport_athlete_football_stat_football_passing_path(@sport, @athlete, @stat, @stat.football_passings)
			elsif !@stat.football_passings.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to add_sport_athlete_football_stat_football_passing_path(@sport, @athlete, @stat, @stat.football_passings) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "rushing"
			if @stat.football_rushings.nil? and params[:stats] == "Game Totals"
				redirect_to new_sport_athlete_football_stat_football_rushing_path(@sport, @athlete, @stat)
			elsif @stat.football_rushings.nil? and params[:stats] == "Play by Play"
				@stat.create_football_rushings
				respond_to do |format|
					format.html { redirect_to add_sport_athlete_football_stat_football_rushing_path(@sport, @athlete, @stat, @stat.football_rushings) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_rushings.nil? and params[:stats] == "Game Totals"
				redirect_to edit_sport_athlete_football_stat_football_rushing_path(@sport, @athlete, @stat, @stat.football_rushings)
			elsif !@stat.football_rushings.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to add_sport_athlete_football_stat_football_rushing_path(@sport, @athlete, @stat, @stat.football_rushings) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "receiving"
			if @stat.football_receivings.nil?
				redirect_to new_sport_athlete_football_stat_football_receiving_path(@sport, @athlete, @stat)
			else
				redirect_to edit_sport_athlete_football_stat_football_receiving_path(@sport, @athlete, @stat, @stat.football_receivings)
			end			
		when "Kicker"
			if @stat.football_kickers.nil? and params[:stats] == "Game Totals"
				redirect_to newkicker_sport_athlete_football_stat_football_kickers_path(sport_id: @sport, 
												athlete_id: @athlete, football_stat_id: @stat)
			elsif @stat.football_kickers.nil? and params[:stats] == "Play by Play"
				@stat.create_football_kickers
				respond_to do |format|
					format.html { redirect_to addplacekicker_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_kickers.nil? and params[:stats] == "Game Totals"
				redirect_to editkicker_sport_athlete_football_stat_football_kickers_path(@sport, @athlete, @stat, @stat.football_kickers)
			elsif !@stat.football_kickers.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to addplacekicker_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "Kickoff"
			if @stat.football_kickers.nil? and params[:stats] == "Game Totals"
				redirect_to newkickoff_sport_athlete_football_stat_football_kickers_path(sport_id: @sport, 
												athlete_id: @athlete, football_stat_id: @stat)
			elsif @stat.football_kickers.nil? and params[:stats] == "Play by Play"
				@stat.create_football_kickers
				respond_to do |format|
					format.html { redirect_to addkickoff_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
				redirect_to addkickoff_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers)
			elsif !@stat.football_kickers.nil? and params[:stats] == "Game Totals"
				redirect_to editkickoff_sport_athlete_football_stat_football_kickers_path(@sport, @athlete, @stat, @stat.football_kickers)
			elsif !@stat.football_kickers.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to addkickoff_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "Punter"
			if @stat.football_kickers.nil? and params[:stats] == "Game Totals"
				redirect_to newpunter_sport_athlete_football_stat_football_kickers_path(sport_id: @sport, 
												athlete_id: @athlete, football_stat_id: @stat)
			elsif @stat.football_kickers.nil? and params[:stats] == "Play by Play"
				@stat.create_football_kickers
				respond_to do |format|
					format.html { redirect_to addpunter_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_kickers.nil? and params[:stats] == "Game Totals"
				redirect_to editpunter_sport_athlete_football_stat_football_kickers_path(@sport, @athlete, @stat, @stat.football_kickers)
			elsif !@stat.football_kickers.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to addpunter_sport_athlete_football_stat_football_kicker_path(@sport, @athlete, @stat, @stat.football_kickers) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "Kick Returner"	
			if @stat.football_returners.nil? and params[:stats] == "Game Totals"
				redirect_to newkoreturn_sport_athlete_football_stat_football_returners_path(sport_id: @sport, 
												athlete_id: @athlete, football_stat_id: @stat)
			elsif @stat.football_returners.nil? and params[:stats] == "Play by Play"
				@stat.create_football_returners
				respond_to do |format|
					format.html { redirect_to addko_sport_athlete_football_stat_football_returner_path(@sport, @athlete, @stat, @stat.football_returners) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_returners.nil? and params[:stats] == "Game Totals"
				redirect_to editkoreturn_sport_athlete_football_stat_football_returners_path(@sport, @athlete, @stat, @stat.football_returners)
			elsif !@stat.football_returners.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to addko_sport_athlete_football_stat_football_returner_path(@sport, @athlete, @stat, @stat.football_returners) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "Punt Returner"
			if @stat.football_returners.nil? and params[:stats] == "Game Totals"
				redirect_to newpuntreturn_sport_athlete_football_stat_football_returners_path(sport_id: @sport, 
												athlete_id: @athlete, football_stat_id: @stat)
			elsif @stat.football_returners.nil? and params[:stats] == "Play by Play"
				@stat.create_football_returners
				respond_to do |format|
					format.html { redirect_to addpunt_sport_athlete_football_stat_football_returner_path(@sport, @athlete, @stat, @stat.football_returners) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_returners.nil? and params[:stats] == "Game Totals"
				redirect_to editpuntreturn_sport_athlete_football_stat_football_returners_path(@sport, @athlete, @stat, @stat.football_returners)
			elsif !@stat.football_returners.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to addpunt_sport_athlete_football_stat_football_returner_path(@sport, @athlete, @stat, @stat.football_returners) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		when "defense"
			if @stat.football_defenses.nil? and params[:stats] == "Game Totals"
				redirect_to new_sport_athlete_football_stat_football_defense_path(@sport, @athlete, @stat)
			elsif @stat.football_defenses.nil? and params[:stats] == "Play by Play"
				@stat.create_football_defenses
				respond_to do |format|
					format.html { redirect_to add_sport_athlete_football_stat_football_defense_path(@sport, @athlete, @stat, @stat.football_defenses) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			elsif !@stat.football_defenses.nil? and params[:stats] == "Game Totals"
				redirect_to edit_sport_athlete_football_stat_football_defense_path(@sport, @athlete, @stat, @stat.football_defenses)
			elsif !@stat.football_defenses.nil? and params[:stats] == "Play by Play"
				respond_to do |format|
					format.html { redirect_to add_sport_athlete_football_stat_football_defense_path(@sport, @athlete, @stat, @stat.football_defenses) }
					format.json { render json: { fbstat: @stat, request: showdata_sport_athlete_football_stats_path(@sport, @athlete) } }
				end
			end
		end
	end

	def showdata
		if params[:game].nil?
			@stats = AthleteFootballStatsTotal.new
			@stats.passing_totals(@athlete)
			@stats.rushing_totals(@athlete)
			@stats.receiving_totals(@athlete)
			@stats.defense_totals(@athlete)
			@stats.specialteams_totals(@athlete)
		else			
			@gamestats = @athlete.football_stats.where(gameschedule_id: params[:game].to_s).first
		end
		respond_to do |format|
			format.json
		end
	end

	def passing
		@stats = []
		@athlete.football_stats.each_with_index do |s, cnt|
			if !s.football_passings.nil?
				@stats[cnt] = s
			end
		end

		if params[:games].nil?
			@passing = AthleteFootballStatsTotal.new
			@passing.passing_totals(@athlete)
		end
		respond_to do |format|
			format.html { render 'athlete_passing_totals' }
			format.json
		end
	end

	def rushing
		@stats = @athlete.football_stats	
		if params[:games].nil?
			@rushing = AthleteFootballStatsTotal.new
			@rushing.rushing_totals(@athlete)
		end
		respond_to do |format|
			format.html { render 'athlete_rushing_totals' }
			format.json
		end
	end

	def defense
		@stats = @athlete.football_stats	
		if params[:games].nil?
			@defense = AthleteFootballStatsTotal.new
			@defense.defense_totals(@athlete)
		end
		respond_to do |format|
			format.html { render 'athlete_defense_totals' }
			format.json
		end		
	end

	def specialteams
		@stats = @athlete.football_stats	
		if params[:games].nil?
			@specialteam = AthleteFootballStatsTotal.new
			@specialteam.specialteams_totals(@athlete)
		end
		respond_to do |format|
			format.html { render 'athlete_specialteam_totals' }
			format.json
		end		
	end

	def receiving
		@stats = @athlete.football_stats	
		if params[:games].nil?
			@receiving = AthleteFootballStatsTotal.new
			@receiving.receiving_totals(@athlete)
		end
		respond_to do |format|
			format.html { render 'athlete_receiving_totals' }
			format.json
		end		
	end

	def edit
	end

	def getrushing
		@stat = @athlete.football_stats.find(params[:id])
		@rushing = @stat.football_rushings
		respond_to do |format|
			format.json { render 'football_rushings/show' }
		end
	end

	def getpassing
		@stat = @athlete.football_stats.find(params[:id])
		@passing = @stat.football_passings
		respond_to do |format|
			format.json { render 'football_passings/show' }
		end
	end

	def getreceiving
		@stat = @athlete.football_stats.find(params[:id])
		@receiving = @stat.football_receivings
		respond_to do |format|
			format.json { render 'football_receivings/show' }
		end
	end

	def getdefense
		@stat = @athlete.football_stats.find(params[:id])
		@receiving = @stat.football_defenses
		respond_to do |format|
			format.json { render 'football_defenses/show' }
		end
	end

	def getkicker
		@stat = @athlete.football_stats.find(params[:id])
		@receiving = @stat.football_kickers
		respond_to do |format|
			format.json { render 'football_kickers/show' }
		end
	end

	def getreturner
		@stat = @athlete.football_stats.find(params[:id])
		@receiving = @stat.football_returners
		respond_to do |format|
			format.json { render 'football_returners/show' }
		end
	end

	def update
		if @stat.update_attributes(params[:stat])
		end
	end

	def destroy
		
	end
	
	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

end
