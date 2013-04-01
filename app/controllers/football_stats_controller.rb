class FootballStatsController < ApplicationController
	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :new, :showdata]
	before_filter	:site_owner?,	        only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete

	def newstat
		@stattype = params[:id]
		if @athlete.team != "Unassigned"
			@games = @sport.teams.find(@athlete.team).gameschedules
		else
			redirect_to :back, error: "Athlete is unnassigned to a team. Stats must be associated with a game which can only be played by teams"
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
			if @stat.football_passings.nil?
				redirect_to new_sport_athlete_football_stat_football_passing_path(@sport, @athlete, @stat)
			else
				redirect_to edit_sport_athlete_football_stat_football_passing_path(@sport, @athlete, @stat, @stat.football_passings)
			end
		when "rushing"
			if @stat.football_rushings.nil?
				redirect_to new_sport_athlete_football_stat_football_rushing_path(@sport, @athlete, @stat)
			else
				redirect_to edit_sport_athlete_football_stat_football_rushing_path(@sport, @athlete, @stat, @stat.football_rushings)
			end			
		when "receiving"
			if @stat.football_receivings.nil?
				redirect_to new_sport_athlete_football_stat_football_receiving_path(@sport, @athlete, @stat)
			else
				redirect_to edit_sport_athlete_football_stat_football_receiving_path(@sport, @athlete, @stat, @stat.football_rushings)
			end			
		when "specialteams"
			if @stat.football_specialteams.nil?
				if params[:specialteams] == "Punter"
					redirect_to newpunter_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				elsif params[:specialteams] == "Kickoff"
					redirect_to newkickoff_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				elsif params[:specialteams] == "Kick Returner"
					redirect_to newkoreturn_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				elsif params[:specialteams] == "Punt Returner"
					redirect_to newpuntreturn_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				else
					redirect_to newkicker_path(sport_id: @sport, athlete_id: @athlete, football_stat_id: @stat)
				end
			else
				if params[:specialteams] == "Punter"
					redirect_to editpunter_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				elsif params[:specialteams] == "Kickoff"
					redirect_to editkickoff_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				elsif params[:specialteams] == "Kick Returner"
					redirect_to editkoreturn_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				elsif params[:specialteams] == "Punt Returner"
					redirect_to editpuntreturn_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				else
					redirect_to editkicker_sport_athlete_football_stat_football_specialteams_path(@sport, @athlete, @stat)
				end
			end			
		when "defense"
			if @stat.football_defenses.nil?
				redirect_to new_sport_athlete_football_stat_football_defense_path(@sport, @athlete, @stat)
			else
				redirect_to edit_sport_athlete_football_stat_football_defense_path(@sport, @athlete, @stat, @stat.football_defenses)
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
#				@pass = s.football_passings
#				@rush = s.football_rushings
#				@rec = s.football_receivings
#				@def = s.football_defenses
#				@spec = s.football_specialteams
#			end
		end
		respond_to do |format|
			format.json
		end
	end

	def passing
		@stats = @athlete.football_stats	
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
