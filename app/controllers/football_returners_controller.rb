class FootballReturnersController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit, :addko, :addpunt, :koreturn, :puntreturn]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :editkoreturn, :editpuntreturn, :update, :destroy, :addko, :addpunt, :koreturn, :puntreturn]
	before_filter only: [:destroy, :update, :create, :edit, :new, :addko, :addpunt, :koreturn, :puntreturn] do |controller| 
	    controller.team_manager?(@athlete, @stat.gameschedule.team)
	end

  	def newkoreturn
		@returner = FootballReturner.new
	end

	def newpuntreturn
		@returner = FootballReturner.new
	end

	def create
		begin
			@returner = @stat.create_football_returners(params[:football_returner])
			if current_user.score_alert? and params[:football_returner][:kotd].to_i > 0
				send_alert(@athlete, "Kickoff Return TD score alert for ")
			elsif current_user.score_alert? and params[:football_returner][:punt_returntd].to_i > 0
				send_alert(@athlete, "Punt Return TD score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Kicker/Punter stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @returner], notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { returner: @returner, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football returner stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
			end
		end
	end

	def show
	end

	def editpuntreturn
	end

	def editkoreturn
	end

	def addpunt
	end

	def addko
	end

	def koreturn
		begin 
			if params[:koyards].to_i > 0
				@returner.koyards = @returner.koyards + params[:koyards].to_i
				@returner.koreturns = @returner.koreturns + 1
			end

			if params[:koyards].to_i > @returner.kolong
				@returner.kolong = params[:koyards].to_i
			end

			if params[:kotd].to_i > 0
				@returner.kotd = @returner.kotd + 1
				gamelog = @returner.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], 
																		  logentry: @athlete.logname + " Kickoff Return " + 
																		  params[:koyards].to_s, score: "TD")
				gamelog.save!
				if params[:quarter]
					@gameschedule = Gameschedule.find(@returner.football_stat.gameschedule)
					case params[:quarter]
					when "Q1"
						@gameschedule.homeq1 = @gameschedule.homeq1 + 6
					when "Q2"
						@gameschedule.homeq2 = @gameschedule.homeq2 + 6
					when "Q3"
						@gameschedule.homeq3 = @gameschedule.homeq3 + 6
					when "Q4"
						@gameschedule.homeq4 = @gameschedule.homeq4 + 6
					end
					@gameschedule.save!
				end
			end
			@returner.save!

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @returner], notice: 'Return stats added for ' + @athlete.full_name }
		        format.json { returner: @returner, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football returner stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
			end
		end
	end

	def puntreturn
		begin 
			if params[:punt_returnyards].to_i > 0
				@returner.punt_returnyards = @returner.punt_returnyards + params[:punt_returnyards].to_i
				@returner.punt_return = @returner.punt_return + 1
			end

			if params[:punt_returnyards].to_i > @returner.punt_returnlong
				@returner.punt_returnlong = params[:punt_returnyards].to_i
			end

			if params[:punt_returntd].to_i > 0
				@returner.punt_returntd = @returner.punt_returntd + 1
				gamelog = @returner.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], 
																		  logentry: @athlete.logname + " Punt Return " + 
																		  params[:punt_returnyards].to_s, score: "TD")
				gamelog.save!
			end
			@returner.save!

			if current_user.score_alert? and params[:kotd].to_i > 0
				send_alert(@athlete, "Kickoff Return TD score alert for ")
			elsif current_user.score_alert? and params[:punt_returntd].to_i > 0
				send_alert(@athlete, "Punt Return TD score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Kicker/Punter stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @returner], notice: 'Return stats added for ' + @athlete.full_name }
		        format.json { render json: { returner: @returner, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football returner stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
			end
		end
	end

	def update
		begin
			@returner.update_attributes!(params[:football_returner])
			if current_user.score_alert? and params[:football_returner][:kotd].to_i > 0
				send_alert(@athlete, "Kickoff Return TD score alert for ")
			elsif current_user.score_alert? and params[:football_returner][:punt_returntd].to_i > 0
				send_alert(@athlete, "Punt Return TD score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Kicker/Punter stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @returner], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json { returner: @returner, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
		     end		
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football returner stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_returner_url(@sport, @athlete, @stat, @returner) } }
			end
		end
	end

	def destroy
		@returner.destroy
		redirect_to specialteams_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@returner = @stat.football_returners
		end

		def send_alert(athlete, message)	
	        Athlete.find(athlete).fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + @stat.gameschedule.game_name, 
	                						   football_stat: @stat.id, stat_football: "Returner")
	        end
		end

	end
