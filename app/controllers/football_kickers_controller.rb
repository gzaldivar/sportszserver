class FootballKickersController < ApplicationController
	before_filter	[:authenticate_user!], [:destroy, :update, :create, :edit, :newkicker, :newpunter, :newkickoff,
											:editkicker, :editpunter, :editkickoff, :addplacekicker, :addpunter, :addkickoff,
										    :placekicker, :punter, :kickoff]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :editkicker, :editpunter, :editkickoff, :update, :destroy,
  												   :addplacekicker, :addpunter, :addkickoff, :placekicker, :punter, :kickoff]
	before_filter only: [:destroy, :update, :create, :edit, :newkicker, :newpunter, :newkickoff,:editkicker, :editpunter, 
						 :editkickoff, :addplacekicker, :addpunter, :addkickoff, :placekicker, :punter, :kickoff] do |controller| 
	    controller.team_manager?(@athlete, @stat.gameschedule.team)
	end

	def newkicker
		@kicker = FootballKicker.new
	end

	def newpunter
		@kicker = FootballKicker.new
	end

	def newkickoff
		@kicker = FootballKicker.new
	end

	def create
		begin
			@kicker = @stat.create_football_kickers(params[:football_kicker])
			if current_user.score_alert? and params[:football_kicker][:fgmade].to_i > 0
				send_alert(@athlete, "Field Goal score alert for ")
			elsif current_user.score_alert? and params[:football_kicker][:xpmade].to_i > 0
				send_alert(@athlete, "Extra Point score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Plack Kicker stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { kicker: @kicker, 
		        			  request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football specialteams stats"	+ e.message	}
				format.json { render status: 404, json: { error: e.message, 
									 request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
			end
		end
	end

	def show
	end

	def editkicker
	end

	def editpunter
	end

	def editkickoff
	end

	def addplacekicker		
	end

	def addpunter
	end

	def addkickoff
	end

	def placekicker		
		begin 
			if params[:fgmissed].to_i > 0 or params[:fgblocked].to_i > 0 or params[:fgmade].to_i > 0
				@kicker.fgattempts = @kicker.fgattempts + 1
			end
			if params[:fgblocked].to_i > 0
				@kicker.fgblocked = @kicker.fgblocked + 1
			end
			if params[:fglong].to_i > @kicker.fglong
				@kicker.fglong = params[:fglong].to_i
			end

			if params[:xpmade].to_i > 0 or params[:xpmissed].to_i > 0 or params[:xpblocked].to_i > 0
				@kicker.xpattempts = @kicker.xpattempts + 1
			end
			if params[:xpmissed].to_i > 0
				@kicker.xpmissed = @kicker.xpmissed + 1
			end
			if params[:xpblocked].to_i > 0
				@kicker.xpblocked = @kicker.xpblocked + 1
			end

			if params[:fgmade].to_i > 0
				@kicker.fgmade = @kicker.fgmade + 1
				gamelog = @kicker.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], 
																		  logentry: @athlete.logname + " " + params[:fglong], score: "FG")
				gamelog.save!
				if params[:quarter]
					@gameschedule = Gameschedule.find(@kicker.football_stat.gameschedule)
					case params[:quarter]
					when "Q1"
						@gameschedule.homeq1 = @gameschedule.homeq1 + 3
					when "Q2"
						@gameschedule.homeq2 = @gameschedule.homeq2 + 3
					when "Q3"
						@gameschedule.homeq3 = @gameschedule.homeq3 + 3
					when "Q4"
						@gameschedule.homeq4 = @gameschedule.homeq4 + 3
					end
					@gameschedule.save!
				end
			elsif params[:xpmade].to_i > 0
				@kicker.xpmade = @kicker.xpmade + 1
				gamelog = @kicker.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], 
																		  logentry: @athlete.logname, score: "XP")
				gamelog.save!
				if params[:quarter]
					@gameschedule = Gameschedule.find(@kicker.football_stat.gameschedule)
					case params[:quarter]
					when "Q1"
						@gameschedule.homeq1 = @gameschedule.homeq1 + 1
					when "Q2"
						@gameschedule.homeq2 = @gameschedule.homeq2 + 1
					when "Q3"
						@gameschedule.homeq3 = @gameschedule.homeq3 + 1
					when "Q4"
						@gameschedule.homeq4 = @gameschedule.homeq4 + 1
					end
					@gameschedule.save!
				end
			end
			@kicker.save!

			if current_user.score_alert? and params[:fgmade].to_i > 0
				send_alert(@athlete, "Field Goal score alert for ")
			elsif current_user.score_alert? and params[:xpmade].to_i > 0
				send_alert(@athlete, "Extra Point score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Plack Kicker stat alert for ")
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Place Kicking stat added for ' + @athlete.full_name }
		        format.json { render json: { kicker: @kicker, 
		        			  request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football specialteams stats"	+ e.message	}
				format.json { render status: 404, json: { error: e.message, 
									 request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
			end
		end
	end

	def kickoff	
		begin 
			if params[:koattempts].to_i > 0
				@kicker.koattempts = @kicker.koattempts + 1
			end
			if params[:kotouchbacks].to_i > 0
				@kicker.kotouchbacks = @kicker.kotouchbacks + 1
			end
			if params[:koreturned].to_i > 0
				@kicker.koreturned = @kicker.koreturned + params[:koreturned].to_i
			end

			@kicker.save!

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Kickoff stats added for ' + @athlete.full_name }
		        format.json { render json: { kicker: @kicker, 
		        			  request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football specialteams stats"	+ e.message	}
				format.json { render status: 404, json: { error: e.message, 
									 request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
			end
		end
	end

	def punter
		begin 
			if params[:punts].to_i > 0
				@kicker.punts = @kicker.punts + 1
			end
			if params[:punts_blocked].to_i > 0
				@kicker.punts_blocked = @kicker.punts_blocked + 1
			end
			if params[:punts_yards].to_i > 0
				@kicker.punts_yards = @kicker.punts_yards + params[:punts_yards].to_i
			end

			if params[:punts_yards].to_i < @kicker.punts_long
				@kicker.punts_long = params[:punts_yards].to_i
			end

			@kicker.save!

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Punter stats added for ' + @athlete.full_name }
		        format.json { render json: { kicker: @kicker, 
		        			  request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football specialteams stats"	+ e.message	}
				format.json { render status: 404, json: { error: e.message, 
									 request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
			end
		end
	end

	def update
		begin
			@kicker.update_attributes(params[:football_kicker])
			if current_user.score_alert? and params[:football_kicker][:fgmade].to_i > 0
				send_alert(@athlete, "Field Goal score alert for ")
			elsif current_user.score_alert? and params[:football_kicker][:xpmade].to_i > 0
				send_alert(@athlete, "Extra Point score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Plack Kicker stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json { render json: { kicker: @kicker, 
		        			  request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating stats for "	+ @athlete.full_name + " " + e.message	}
				format.json { render status: 404, json: { error: e.message, 
									 request: sport_athlete_football_stat_football_kicker_url(@sport, @athlete, @stat, @kicker) } }
			end
		end
	end

	def destroy
		@kicker.destroy
		redirect_to specialteams_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@kicker = @stat.football_kickers
		end

		def send_alert(athlete, message)	
	        Athlete.find(athlete).fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + @stat.gameschedule.game_name, 
	                						   football_stat: @stat.id, stat_football: "Kicker")
	        end
		end

end
