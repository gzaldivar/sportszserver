class FootballPuntersController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.SiteOwner?(@athlete.team_id)
	end
	before_filter do |check|
		check.packageEnabled?(current_site)
	end

  	def new
		@punter = FootballPunter.new(gameschedule_id: params[:gameschedule_id])
		@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id].to_s)

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
  	end

  	def create
		begin
			if params[:football_punter].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_punter][:gameschedule_id].to_s)
				live = params[:football_punter][:livestats].to_s
			end

			if live == "Totals"
				punter = @athlete.football_punters.create!(params[:football_punter])
			else
				punter = @athlete.football_punters.new(gameschedule_id: game.id.to_s)
				livestats(punter, params)
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { punter: punter } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating punter stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
  	end

  	def show
		if params[:stat_id]
			@punter = FootballPunter.find(params[:stat_id])
		else
			@punter = FootballPunter.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@punter.gameschedule_id)
  	end

  	def update
		begin
			if params[:football_punter].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_punter][:livestats].to_s
			end

			if live == "Totals"
				@punter.update_attributes!(params[:football_punter])
			elsif live == "Adjust"
				adjust(@punter, params)
			else
				livestats(@punter, params)
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @gameschedule.team_id, 
		        								id: @gameschedule.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { punter: @punter } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating punter stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

  	def index
  		fbstats = Punterstats.new(@sport, @athlete)
  		@stats = fbstats.stats
  		@totals = fbstats.puntertotals
  	end

  	def destroy
  		begin
  			@punter.destroy
  			respond_to do |format|
  				format.html { redirect_to sport_athlete_path(@sport, @athlete) }
  				format.json { render status: 200, json: { message: "Success" } }
  			end
  		rescue Exception => e
 			respond_to do |format|
				format.html { redirect_to sport_athlete_path(@sport, @athlete), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
  		end
  	end

  	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def correct_stat
			@punter = @athlete.football_punters.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@punter.gameschedule_id)
		end

		def send_alert(athlete, message, stat, game)	
	        athlete.fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + game.game_name, 
	                						   football_punter: stat.id, stat_football: "Punter")
	        end
		end

		def livestats(stat, params)
			if params[:punts].to_i > 0
				stat.punts += 1
			end

			if params[:punts_blocked].to_i > 0
				stat.punts_blocked += 1
			end

			if params[:punts_yards].to_i > 0
				stat.punts_yards += params[:punts_yards].to_i
			end

			if stat.punts_long < params[:punts_yards].to_i
				stat.punts_long = params[:punts_yards].to_i
			end

			stat.save!
		end

		def adjust(stat, params)
			if params[:punts].to_i > 0
				stat.punts -= 1
			end

			if params[:punts_blocked].to_i > 0
				stat.punts_blocked -= 1
			end

			if params[:punts_yards].to_i > 0
				stat.punts_yards -= params[:punts_yards].to_i
			end

			stat.save!
		end
end
