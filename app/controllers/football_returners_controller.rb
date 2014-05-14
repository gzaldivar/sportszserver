class FootballReturnersController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.SiteOwner?(@athlete.team_id)
	end
#	before_filter do |check|
#		check.packageEnabled?(current_site)
#	end

  	def new
		@returner = FootballReturner.new(gameschedule_id: params[:gameschedule_id])
		@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id].to_s)

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			if params[:football_returner].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_returner][:gameschedule_id].to_s)
				live = params[:football_returner][:livestats].to_s
			end

			if live == "Totals"
				returner = @athlete.football_returners.create!(params[:football_returner])

			else
				returner = @athlete.football_returners.new(gameschedule_id: game.id.to_s)
				livestats(returner, @athlete, params, game)
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { returner: returner } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football returner stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show
		if params[:stat_id]
			@returner = FootballReturner.find(params[:stat_id])
		else
			@returner = FootballReturner.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@returner.gameschedule_id)
	end

	def index
		fbstats = Returnerstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.returnertotals
	end

	def update
		begin
			if params[:football_defense].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_defense][:livestats].to_s
			end

			if live == "Totals"
				@returner.update_attributes!(params[:football_returner])

			elsif live == "Adjust"
				adjust(@returner, @athlete, params)
			else
				livestats(@returner, @athlete, params, @gameschedule)
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @gameschedule.team_id, 
		        								id: @gameschedule.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { returner: @returner } }
		     end		
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football returner stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def destroy
		begin
			@returner.destroy
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
			@returner = @athlete.football_returners.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@returner.gameschedule_id)
		end

		def send_alert(athlete, message, stat, game, gamelog)	
	        athlete.fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + game.game_name, 
	                						   football_returner: stat.id, stat_football: "Returner", team: game.team_id, gamelog: gamelog.id)
	        end
		end

		def livestats(stat, athlete, params, game)
			if params[:punt_returnyards].to_i > 0
				stat.punt_returnyards = stat.punt_returnyards + params[:punt_returnyards].to_i
				stat.punt_return = stat.punt_return + 1
			end

			if params[:punt_returnyards].to_i > stat.punt_returnlong
				stat.punt_returnlong = params[:punt_returnyards].to_i
			end

			if params[:punt_returntd].to_i > 0
				stat.punt_returntd = stat.punt_returntd + 1
			elsif params[:kotd].to_i > 0
				stat.kotd = stat.kotd + 1
			end


			if params[:koyards].to_i > 0
				stat.koyards = stat.koyards + params[:koyards].to_i
				stat.koreturns = stat.koreturns + 1
			end

			if params[:koyards].to_i > stat.kolong
				stat.kolong = params[:koyards].to_i
			end

			stat.save!

			if params[:punt_returntd].to_i > 0

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "punt return", score: "TD", 
												yards: params[:punt_returnyards], football_returner_id: stat.id)
					gamelog.save!
					if params[:quarter]
						case params[:quarter]
						when "Q1"
							game.homeq1 = game.homeq1 + 6
						when "Q2"
							game.homeq2 = game.homeq2 + 6
						when "Q3"
							game.homeq3 = game.homeq3 + 6
						when "Q4"
							game.homeq4 = game.homeq4 + 6
						end
						game.save!
					end
				end
			elsif params[:kotd].to_i > 0

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "kickoff return", score: "TD", 
												yards: params[:koyards], football_returner_id: stat.id)

					gamelog.save!
					if params[:quarter]
						case params[:quarter]
						when "Q1"
							game.homeq1 = game.homeq1 + 6
						when "Q2"
							game.homeq2 = game.homeq2 + 6
						when "Q3"
							game.homeq3 = game.homeq3 + 6
						when "Q4"
							game.homeq4 = game.homeq4 + 6
						end
						game.save!
					end
				end
			end
			
			if current_user.score_alert? and params[:kotd].to_i > 0
				send_alert(athlete, "Kickoff Return TD score alert for ", stat, game, gamelog)
			elsif current_user.score_alert? and params[:punt_returntd].to_i > 0
				send_alert(athlete, "Punt Return TD score alert for ", stat, game, gamelog)
			elsif current_user.stat_alert?
				send_alert(athlete, "Return stat alert for ", stat, game, gamelog)
			end
		end

		def adjust(stat, athlete, params)
			if params[:koyards].to_i > 0 and stat.koyards > params[:koyards].to_i
				stat.koyards -= params[:koyards].to_i
			elsif stat.koyards > params[:koyards].to_i
				raise "Entry exceeds current kickoff return yards"
			end

			if params[:punt_returnyards].to_i > 0 and stat.punt_returnyards > params[:punt_returnyards].to_i
				stat.punt_returnyards -= params[:punt_returnyards].to_i
			elsif stat.punt_returnyards > params[:punt_returnyards].to_i
				raise "Entry exceeds current punt return yards"
			end
			stat.save!
		end
end
