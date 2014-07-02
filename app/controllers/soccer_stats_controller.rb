class SoccerStatsController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_stat, only: [:update, :destroy, :show, :edit]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		if @athlete
			controller.SiteOwner?(@athlete.team_id)
		else
			controller.SiteOwner?(@gameschedule.team_id)
		end
	end

	def index
	end

	def new
		if @athlete
			@soccer_stat = @athlete.soccer_stats.new
		else
			@soccer_stat = @soccer_game.soccer_stats.new
		end
	end

	def create
		begin
			if @athlete
				@soccer_stat = @athlete.soccer_stats.create!(params[:soccer_stat])
			else
				@soccer_stat = @soccer_game.soccer_stats.new(athlete_id: params[:player_id])
#				@soccer_stat = @soccer_game.soccer_stats.create!(params[:soccer_stat])
			end

			@soccer_stat.save!

			if params[:playerstat]
				process_playerstats(@soccer_stat, params[:period].to_i)
			elsif params[:goalstat]
				process_goalstats(@soccer_stat, params[:period].to_i)
			elsif params[:scorestat]
				process_scoring(@soccer_stat, params[:period].to_i)
			else
				process_playerpenalty(@soccer_stat, params[:period].to_i)
			end

			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athletes_soccer_stats_path(@sport, @athlete), notice: "Stats Updated!" 
								else
									redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: "Stats Updated!"
								end
							}
				format.json { render 'show' }
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athletes_soccer_stats_path(@sport, @athlete), alert: e.message
								else
									redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), alert: e.message
								end
							}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show	
	end

	def edit
		
	end

	def update
		begin
			@soccer_stat.update_attributes!(params[:soccer_stat])

			if params[:playerstat]
				process_playerstats(@soccer_stat, params[:period].to_i)
			elsif params[:goalstat]
				process_goalstats(@soccer_stat, params[:period].to_i)
			elsif params[:scorestat]
				process_scoring(@soccer_stat, params[:period].to_i)
			else
				process_playerpenalty(@soccer_stat, params[:period].to_i)
			end

			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athletes_soccer_stats_path(@sport, @athlete), notice: "Stats Updated!"
								else
									redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: "Stats Updated!"
								end 
							}
				format.json { render 'show' }
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athletes_soccer_stats_path(@sport, @athlete), alert: e.message
								else
									redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), alert: e.message
								end
							}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def destroy
		begin
			if params[:soccer_playerstat]
				@soccer_stat.soccer_playerstats.find(params[:soccer_playerstat]).destroy
			elsif params[:soccer_goalstat]
				@soccer_stat.soccer_goalstats.find(params[:soccer_goalstat]).destroy
			elsif params[:soccer_scoring]
				@soccer_stat.soccer_scorings.find(params[:soccer_scoring]).destroy
			else
				@soccer_stat.soccer_penalties.find(params[:soccer_penalty]).destroy
			end

			if @soccer_stat.soccer_playerstats.nil? and @soccer_stat.soccer_goalstats.nil? and @soccer_stat.soccer_scorings.nil? and 
				@soccer_stat.soccer_penalties.nil?
				@soccer_stat.destroy!
			end

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: "Delete Succesful!" }
				format.json { render status: 200, json: { success: 'success' } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])

			if params[:athlete_id]
				@athlete = Athlete.find(params[:athlete_id])
			else
				@team = @sport.teams.find(params[:team_id])
				@gameschedule = @team.gameschedules.find(params[:gameschedule_id])
				@soccer_game = @gameschedule.soccer_game
			end
		end

		def get_stat
			if @athlete.nil?
				@soccer_stat = @soccer_game.soccer_stats.find(params[:id])
			else
				@soccer_stat = @athlete.soccer_stats.find(params[:id])
			end
		end

		def process_playerstats(stats, period)
			playerstat = stats.soccer_playerstats.find_by(period: period)

			if playerstat.nil?
				playerstat = stats.soccer_playerstats.new(period: period)
			end

			playerstat.shots = params[:shots].to_i if params[:shots]
			playerstat.cornerkick = params[:cornerkick].to_i if params[:cornerkick]
			playerstat.steals = params[:steals].to_i if params[:steals]
			playerstat.fouls = params[:fouls].to_i if params[:fouls]
			playerstat.save!
		end

		def process_scoring(stats, period)
			scorestat = stats.soccer_scorings.find_by(period: period)

			if scorestat.nil?
				scorestat = stats.soccer_scorings.new(period: period)
			end

			if params[:assist_id]
				scorestat.assist = params[:assist_id]
			end

			scorestat.gametime = params[:minutes] + ':' + params[:seconds]
			scorestat.save!
		end

		def process_goalstats(stats, period)
			goalstat = stats.soccer_goalstats.find_by(period: period)

			if goalstat.nil?
				goalstat = stats.soccer_goalstats.new(period: period)
			end

			goalstat.saves = params[:saves].to_i
			goalstat.minutesplayed = params[:minutesplayed].to_i
			goalstat.goals_allowed = params[:goals_allowed].to_i
			scorestat.save!
		end

		def process_playerpenalty(stats, period)
			penaltystat = stats.soccer_penalties.find_by(period: period)

			if penaltystat.nil?
				penaltystat = stats.soccer_penalties.new(period: period)
			end

			if params[:yellowcard]
				penaltystat.infraction = params[:yellowcard]
				penaltystat.card = 'Y'
			elsif params[:redcard]
				penaltystat.infraction = params[:redcard]
				penaltystat.card = 'R'
			else
				raise 'Yellow or Red card infraction must be selected'
			end

			penaltystat.gametime = params[:minutes] + ':' + params[:seconds]
			penaltystat.save!
		end

end
