class HockeyStatsController < ApplicationController
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
			@hockey_stat = @athlete.hockey_stats.new
		else
			@hockey_stat = @hockey_game.hockey_stats.new
		end
	end

	def create
		begin
			if @athlete
				@hockey_stat = @athlete.hockey_stats.new(hockey_game_id: params[:hockey_game_id])
				game = Gameschedule.find_by('hockey_game._id' => Moped::BSON::ObjectId(params[:hockey_game_id]))
				@hockey_game = game.hockey_game
			else
				@hockey_stat = @hockey_game.hockey_stats.find_by(athlete_id: params[:player_id])

				if @hockey_stat.nil?
					@hockey_stat = @hockey_game.hockey_stats.new(athlete_id: params[:player_id])
				end
			end

			@hockey_stat.save!

			if params[:playerstat]
				process_playerstats(@hockey_stat, params[:period].to_i)
			elsif params[:goalstat]
				process_goalstats(@hockey_stat, params[:period].to_i)
			elsif params[:scorestat]
				process_scoring(@hockey_stat, params[:period].to_i)
			else
				process_playerpenalty(@hockey_stat, params[:period].to_i)
			end

			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_hockey_stat_path(@sport, @athlete, @hockey_stat), notice: "Stats Updated!" 
								else
									redirect_to sport_team_gameschedule_hockey_games_path(@sport, @team, @gameschedule, @hockey_game), notice: "Stats Updated!"
								end
							}
				format.json
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_hockey_stat_path(@sport, @athlete), alert: e.message
								else
									redirect_to sport_team_gameschedule_hockey_games_path(@sport, @team, @gameschedule, @hockey_game), alert: e.message
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
			@hockey_stat.update_attributes!(params[:soccer_stat])
			game = Gameschedule.find_by('hockey_game._id' => Moped::BSON::ObjectId(params[:hockey_game_id]))
			@hockey_game = game.hockey_game

			if params[:playerstat]
				process_playerstats(@hockey_stat, params[:period].to_i)
			elsif params[:goalstat]
				process_goalstats(@hockey_stat, params[:period].to_i)
			elsif params[:scorestat]
				process_scoring(@hockey_stat, params[:period].to_i)
			else
				process_playerpenalty(@hockey_stat, params[:period].to_i)
			end

			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_hockey_stat_path(@sport, @athlete, @hockey_stat), notice: "Stats Updated!" 
								else
									redirect_to sport_team_gameschedule_hockey_games_path(@sport, @team, @gameschedule, @hockey_game), notice: "Stats Updated!"
								end
							}
				format.json
			end						
		rescue Exception => e
			respond_to do |format|
				format.html { 	if @athlete
									redirect_to sport_athlete_hockey_stat_path(@sport, @athlete), alert: e.message
								else
									redirect_to sport_team_gameschedule_hockey_games_path(@sport, @team, @gameschedule, @hockey_game), alert: e.message
								end
							}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def destroy
		begin
			if params[:hockey_playerstat]
				@hockey_stat.hockey_playerstats.find(params[:hockey_playerstat]).destroy
			elsif params[:hockey_goalstat]
				@hockey_stat.hockey_goalstats.find(params[:hockey_goalstat]).destroy
			elsif params[:hockey_scoring]
				@hockey_stat.hockey_scorings.find(params[:hockey_scoring]).destroy
			else
				@hockey_stat.hockey_penalties.find(params[:hockey_penalty]).destroy
			end

			if @hockey_stat.hockey_playerstats.nil? and @hockey_stat.hockey_goalstats.nil? and @hockey_stat.hockey_scorings.nil? and 
				@hockey_stat.hockey_penalties.nil?
				@hockey_stat.destroy!
			end

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_hockey_games_path(@sport, @team, @gameschedule, @hockey_game), notice: "Delete Succesful!" }
				format.json 
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_hockey_games_path(@sport, @team, @gameschedule, @hockey_game), alert: e.message }
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
				@hockey_game = @gameschedule.hockey_game
			end
		end

		def get_stat
			if @athlete.nil?
				@hockey_stat = @hockey_game.hockey_stats.find(params[:id])
			else
				@hockey_stat = @athlete.hockey_stats.find(params[:id])
			end
		end

		def process_playerstats(stats, period)
			playerstat = stats.hockey_playerstats.find_by(period: period)

			if playerstat.nil?
				playerstat = stats.hockey_playerstats.new(period: period)
			end

			playerstat.shots = params[:shots].to_i if params[:shots]
			playerstat.save!
		end

		def process_scoring(stats, period)
			scorestat = stats.hockey_scorings.find_by(period: period)

			if scorestat.nil?
				scorestat = stats.hockey_scorings.new(period: period)
			end

			if params[:assist] and !params[:assist].blank?
				scorestat.assist = params[:assist]
				scorestat.assist_type = params[:assist_type]
			end

			scorestat.gametime = params[:minutes] + ':' + params[:seconds]
			scorestat.goaltype = params[:goaltype]
			scorestat.save!
		end

		def process_goalstats(stats, period)
			goalstat = stats.hockey_goalstats.find_by(period: period)

			if goalstat.nil?
				goalstat = stats.hockey_goalstats.new(period: period)
			end

			goalstat.saves = params[:saves].to_i
			goalstat.minutesplayed = params[:minutesplayed].to_i
			goalstat.goals_allowed = params[:goals_allowed].to_i
			goalstat.save!
		end

		def process_playerpenalty(stats, period)
			penaltystat = stats.hockey_penalties.find_by(period: period)

			if penaltystat.nil?
				penaltystat = stats.hockey_penalties.new(period: period)
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
