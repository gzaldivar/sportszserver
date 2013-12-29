class FootballKickersController < ApplicationController
	include FootballStatistics
	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:update, :destroy,] do |controller| 
	    controller.team_manager?(@athlete, nil)
	end

	def new
		@kicker = FootballKicker.new(gameschedule_id: params[:gameschedule_id])
		@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id].to_s)

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			if params[:football_kicker].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_kicker][:gameschedule_id].to_s)
				live = params[:football_kicker][:livestats].to_s
			end

			if live == "Totals"
				kicker = @athlete.football_kickers.create!(params[:football_kicker])

				if current_user.stat_alert?
					send_alert(@athlete, "Plack Kicker stat alert for ", kicker, game)
				end
			else
				kicker = @athlete.football_kickers.new(gameschedule_id: game.id.to_s)
				livestats(kicker, params)
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { kicker: kicker } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football kicker stats"	+ e.message	}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show
		if params[:stat_id]
			@kicker = FootballKicker.find(params[:stat_id])
		else
			@kicker = FootballKicker.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@kicker.gameschedule_id)
	end

	def index
		fbstats = Kickerstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.kickertotals
	end

	def update
		begin
			if params[:football_kicker].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_kicker][:livestats].to_s
			end

			if live == "Totals"
				@kicker.update_attributes!(params[:football_kicker])

				if current_user.stat_alert?
					send_alert(@athlete, "Plack Kicker stat alert for ",  @kicker,  @gameschedule)
				end
			elsif live == "Adjust"
				adjust(@kicker, params)
			else
				livestats(@kicker, params)
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @gameschedule.team_id, 
		        								id: @gameschedule.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { kicker: @kicker } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating stats for "	+ @athlete.full_name + " " + e.message	}
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def destroy
		@kicker.destroy
		redirect_to sport_athlete_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def correct_stat
			@kicker = @athlete.football_kickers.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@kicker.gameschedule_id)
		end

		def send_alert(athlete, message, stat, game)	
	        Athlete.find(athlete).fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + game.game_name, 
	                						   football_kicker: stat.id, stat_football: "Kicker")
	        end
		end

		def livestats(stat, params)
			if params[:koattempts].to_i > 0
				stat.koattempts = stat.koattempts + 1
			end
			if params[:kotouchbacks].to_i > 0
				stat.kotouchbacks = stat.kotouchbacks + 1
			end
			if params[:koreturned].to_i > 0
				stat.koreturned = stat.koreturned + params[:koreturned].to_i
			end

			stat.save!
		end

		def adjust(stat, params)
			if params[:koattempts].to_i > 0
				stat.koattempts -= 1
			end

			if params[:kotouchbacks].to_i > 0
				stat.kotouchbacks -= 1
			end

			if params[:koreturned].to_i > 0
				stat.koreturned -= 1
			end
			
			stat.save!
		end

end
