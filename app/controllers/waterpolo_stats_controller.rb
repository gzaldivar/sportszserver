class WaterpoloStatsController < ApplicationController
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
			@waterpolo_stat = @athlete.waterpolo_stats.new
		else
			@waterpolo_stat = @water_polo_game.waterpolo_stats.new
		end
	end

	def create
		begin
			if @athlete
				@waterpolo_stat = @athlete.waterpolo_stats.new(water_polo_game_id: params[:water_polo_game_id])
				game = Gameschedule.find_by('water_polo_game._id' => Moped::BSON::ObjectId(params[:water_polo_game_id]))
				@water_polo_game = game.water_polo_game
			else
				@waterpolo_stat = @water_polo_game.waterpolo_stats.find_by(athlete_id: params[:player_id])

				if @waterpolo_stat.nil?
					@waterpolo_stat = @water_polo_game.waterpolo_stats.new(athlete_id: params[:player_id])
				end
			end

			@waterpolo_stat.save!

			if params[:playerstat]
				process_playerstats(@waterpolo_stat, params[:period].to_i)
			elsif params[:goalstat]
				process_goalstats(@waterpolo_stat, params[:period].to_i)
			elsif params[:scorestat]
				process_scoring(@waterpolo_stat, params[:period].to_i)
			else
				process_playerpenalty(@waterpolo_stat, params[:period].to_i)
			end

			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_waterpolo_stat_path(@sport, @athlete, @waterpolo_stat), notice: "Stats Updated!" 
								else
									redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), notice: "Stats Updated!"
								end
							}
				format.json
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_waterpolo_stat_path(@sport, @athlete), alert: e.message
								else
									redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), alert: e.message
								end
							}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def edit
		
	end

	def show
		
	end

	def update
		begin
			@waterpolo_stat.update_attributes!(params[:soccer_stat])
			game = Gameschedule.find_by('water_polo_game._id' => Moped::BSON::ObjectId(params[:water_polo_game_id]))
			@water_polo_game = game.water_polo_game

			if params[:playerstat]
				process_playerstats(@waterpolo_stat, params[:period].to_i)
			elsif params[:goalstat]
				process_goalstats(@waterpolo_stat, params[:period].to_i)
			elsif params[:scorestat]
				process_scoring(@waterpolo_stat, params[:period].to_i)
			else
				process_playerpenalty(@waterpolo_stat, params[:period].to_i)
			end

			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_waterpolo_stat_path(@sport, @athlete, @waterpolo_stat), notice: "Stats Updated!" 
								else
									redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), notice: "Stats Updated!"
								end
							}
				format.json
			end						
		rescue Exception => e
			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_waterpolo_stat_path(@sport, @athlete), alert: e.message
								else
									redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), alert: e.message
								end
							}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def destroy
		begin
			if params[:waterpolo_playerstat]
				@waterpolo_stat.waterpolo_playerstats.find(params[:waterpolo_playerstat]).destroy
			elsif params[:waterpolo_goalstat]
				@waterpolo_stat.waterpolo_goalstats.find(params[:waterpolo_goalstat]).destroy
			elsif params[:waterpolo_scoring]
				@waterpolo_stat.waterpolo_scorings.find(params[:waterpolo_scoring]).destroy
			else
				@waterpolo_stat.waterpolo_penalties.find(params[:waterpolo_penalty]).destroy
			end

			if @waterpolo_stat.waterpolo_playerstats.nil? and @waterpolo_stat.waterpolo_goalstats.nil? and @waterpolo_stat.waterpolo_scorings.nil? and 
				@waterpolo_stat.waterpolo_penalties.nil?
				@waterpolo_stat.destroy!
			end

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), notice: "Delete Succesful!" }
				format.json 
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), alert: e.message }
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
				@water_polo_game = @gameschedule.water_polo_game
			end
		end

		def get_stat
			if @athlete.nil?
				@waterpolo_stat = @water_polo_game.waterpolo_stats.find(params[:id])
			else
				@waterpolo_stat = @athlete.waterpolo_stats.find(params[:id])
			end
		end

		def process_playerstats(stats, period)
			playerstat = stats.waterpolo_playerstats.find_by(period: period)

			if playerstat.nil?
				playerstat = stats.waterpolo_playerstats.new(period: period)
			end

			playerstat.shots = params[:shots].to_i if params[:shots]
			playerstat.steals = params[:steals].to_i if params[:steals]
			playerstat.fouls = params[:fouls].to_i if params[:fouls]
			playerstat.save!
		end

		def process_scoring(stats, period)
			scorestat = stats.waterpolo_scorings.find_by(period: period)

			if scorestat.nil?
				scorestat = stats.waterpolo_scorings.new(period: period)
			end

			if params[:assist] and !params[:assist].blank?
				scorestat.assist = params[:assist]
			end

			scorestat.gametime = params[:minutes] + ':' + params[:seconds]
			scorestat.save!
		end

		def process_goalstats(stats, period)
			goalstat = stats.waterpolo_goalstats.find_by(period: period)

			if goalstat.nil?
				goalstat = stats.waterpolo_goalstats.new(period: period)
			end

			goalstat.saves = params[:saves].to_i
			goalstat.minutesplayed = params[:minutesplayed].to_i
			goalstat.goals_allowed = params[:goals_allowed].to_i
			goalstat.save!
		end

		def process_playerpenalty(stats, period)
			penaltystat = stats.waterpolo_penalties.find_by(period: period)

			if penaltystat.nil?
				penaltystat = stats.waterpolo_penalties.new(period: period)
			end

			if params[:yellowcard]
				penaltystat.infraction = params[:yellowcard]
				penaltystat.card = 'Y'
			elsif params[:redcard]
				penaltystat.infraction = params[:redcard]
				penaltystat.card = 'R'
			end

			penaltystat.gametime = params[:minutes] + ':' + params[:seconds]
			penaltystat.save!
		end

end
