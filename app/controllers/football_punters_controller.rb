class FootballPuntersController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.team_manager?(@athlete, nil)
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
				returner = @athlete.football_punters.create!(params[:football_punter])

				if current_user.stat_alert?
					send_alert(@athlete, "Punter stat alert for ", punter, game)
				end
			else
				punter = @athlete.football_punters.new(gameschedule_id: game.id.to_s)
				livestats(punter, params)
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, punter], notice: 'Stat created for ' + @athlete.full_name }
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
  	end

  	def edit
		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Adjust"
			@live = "Adjust"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
  	end

  	def update
		begin
			if params[:football_punter].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_punter][:livestats].to_s
			end

			if live == "Totals"
				returner = @athlete.update_attributes!(params[:football_punter])

				if current_user.stat_alert?
					send_alert(@athlete, "Punter stat alert for ", @punter, @gameschedule)
				end
			elsif live == "Adjust"
				adjust(@punter, params)
			else
				livestats(@punter, params)
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @punter], notice: 'Stat created for ' + @athlete.full_name }
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
