class FootballPassingsController < ApplicationController
	before_filter	[:authenticate_user!],	only: [:destroy, :update, :create, :edit, :new, :add, :addattempt]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy, :add, :addattempt]
	before_filter only: [:destroy, :update, :create, :edit, :new, :add, :addattempt] do |controller| 
	    controller.team_manager?(@athlete, @stat.gameschedule.team)
	end

	def new
		@fbpassing = FootballPassing.new
	end

	def create
		begin
			@fbpassing = @stat.create_football_passings(params[:football_passing])
			if current_user.score_alert? and (params[:football_passing][:td].to_i > 0 or params[:football_passing][:twopointconv].to_i > 0)
				send_alert(@athlete, "Passing score alert for ")
			elsif current_user.stat_alert? and (params[:football_passing][:td].to_i == 0 or params[:football_passing][:twopointconv].to_i == 0)
				send_alert(@athlete, "Passing stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { passing: @fbpassing, 
		        			  request: sport_athlete_football_stat_football_passing_url(@sport, @athlete, @stat, @fbpassing) } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football passing stats " + e.message }
		        format.json { render json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_passing_url(@sport, @athlete, @stat, @fbpassing) } }
		     end			
		end
	end

	def show
	end

	def add
		if params[:id]
			@fbpassing = @stat.football_passings
		else
			@fbpassing = FootballPassing.new().save!
		end
	end

	def addattempt
		begin
			receiver = nil
			player = nil
			@fbpassing.attempts = @fbpassing.attempts + 1

			if params[:comp].to_i > 0
				@fbpassing.completions = @fbpassing.completions + 1
				@fbpassing.yards = @fbpassing.yards + params[:yards].to_i
				@fbpassing.yards_lost = @fbpassing.yards_lost + params[:yards_lost].to_i

				if params[:fd].to_i > 0
					@fbpassing.firstdowns = @fbpassing.firstdowns + 1
				end

				if !params[:receiver].nil? and !params[:receiver].blank?
					player = @sport.athletes.find(params[:receiver])
					stat = nil

					if player.football_stats.nil?
						stat = player.football_stats.create!(gameschedule: @fbpassing.football_stat.gameschedule)
					elsif player.football_stats.find_by(gameschedule: @fbpassing.football_stat.gameschedule).nil?
						stat = player.football_stats.create!(gameschedule: @fbpassing.football_stat.gameschedule)
					else
						stat = player.football_stats.find_by(gameschedule: @fbpassing.football_stat.gameschedule)
					end

					if stat.football_receivings.nil?
						receiver = stat.create_football_receivings(receptions: 1, yards: params[:yards].to_i, longest: params[:yards].to_i)
					else
						receiver = stat.football_receivings
						receiver.receptions = receiver.receptions + 1
						receiver.yards = receiver.yards + params[:yards].to_i

						if receiver.longest < params[:yards].to_i
							receiver.longest = params[:yards].to_i
						end
					end

					if params[:td].to_i > 0
						receiver.td = receiver.td + 1
					end

					if params[:rec_fumble].to_i > 0
						receiver.fumbles = receiver.fumbles + 1
					end

					if params[:rec_fumble_lost].to_i > 0
						receiver.fumbles_lost = receiver.fumbles_lost + 1
					end

					receiver.save!		
				end

				if params[:td].to_i > 0
					@fbpassing.td = @fbpassing.td + 1

					if !receiver.nil? and !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
						gamelog = @fbpassing.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																		 logentry: @athlete.logname + " " + params[:yards] + " yards to " + 
																		 player.logname, score: "TD")
						gamelog.save!
						if params[:quarter]
							@gameschedule = Gameschedule.find(@fbpassing.football_stat.gameschedule)
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
				end

				if params[:two].to_i > 0
					@fbpassing.twopointconv = @fbpassing.twopointconv + 1

					if !receiver.nil? and !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
						gamelog = @fbpassing.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																		 logentry: @athlete.logname + " " + params[:yards] + "yards to " + 
																		 player.logname, score: "2P")
						gamelog.save!
						if params[:quarter]
							@gameschedule = Gameschedule.find(@fbpassing.football_stat.gameschedule)
							case params[:quarter]
							when "Q1"
								@gameschedule.homeq1 = @gameschedule.homeq1 + 2
							when "Q2"
								@gameschedule.homeq2 = @gameschedule.homeq2 + 2
							when "Q3"
								@gameschedule.homeq3 = @gameschedule.homeq3 + 2
							when "Q4"
								@gameschedule.homeq4 = @gameschedule.homeq4 + 2
							end
							@gameschedule.save!
						end
					end
				end

				if params[:sack].to_i > 0
					@fbpassing.sacks = @fbpassing.sacks + 1
				end

				if params[:int].to_i > 0
					@fbpassing.interceptions = @fbpassing.interceptions + 1
				end
						
				if current_user.score_alert? and params[:td].to_i > 0
					send_alert(@athlete, "Passing score alert for ")
					send_alert(player, "Receiver score alert for ")
				elsif current_user.stat_alert? and params[:td].to_i == 0
					send_alert(@athlete, "Passing stat alert for ")
					send_alert(player, "Receiver stat alert for ")
				end
			end
			@fbpassing.save!

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Passing entry added for ' + @athlete.full_name }
		        format.json { render json: { passing: @fbpassing, 
		        			  request: sport_athlete_football_stat_football_passing_url(@sport, @athlete, @stat, @fbpassing) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error: " + e.message }
				format.json { render json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_passing_url(@sport, @athlete, @stat, @fbpassing) } }
		    end
		end
	end


	def edit		
	end

	def update		
		begin
			@fbpassing.update_attributes!(params[:football_passing])
			if current_user.score_alert? and (params[:football_passing][:td].to_i > 0  or params[:football_passing][:twopointconv].to_i > 0)
				send_alert(@athlete, "Passing score alert for ")
			elsif current_user.stat_alert? and (params[:football_passing][:td].to_i == 0 or params[:football_passing][:twopointconv].to_i == 0)
				send_alert(@athlete, "Passing stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json { render json: { passing: @fbpassing, 
		        			  request: sport_athlete_football_stat_football_passing_url(@sport, @athlete, @stat, @fbpassing) } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating stats for " + @athlete.full_name + " " + e.message }
		        format.json { render json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_passing_url(@sport, @athlete, @stat, @fbpassing) } }
		     end			
		end
	end

	def destroy
		@fbpassing.destroy
		redirect_to passing_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@fbpassing = @stat.football_passings

		end
		
		def send_alert(athlete, message)	
	        Athlete.find(athlete).fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + @stat.gameschedule.game_name, 
	                						   football_stat: @stat.id, stat_football: "Passing")
	        end
		end

end
