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
			if current_user.score_alert? and params[:football_passing][:td].to_i > 0
				send_alert(@athlete, "Passing score alert for ")
			elsif current_user.stat_alert? and params[:football_passing][:td].to_i == 0
				send_alert(@athlete, "Passing stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error creating football passing stats " + e.message
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

					if !receiver.nil?
						gamelog = @fbpassing.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																		 logentry: @athlete.logname + " " + params[:yards] + "yards to " + 
																		 player.logname, score: "TD")
						gamelog.save!
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
		        format.json 
		    end
		rescue Exception => e
			redirect_to :back, alert: "Error: " + e.message
		end
	end


	def edit		
	end

	def update		
		begin
			@fbpassing.update_attributes!(params[:football_passing])
			if current_user.score_alert? and params[:football_passing][:td].to_i > 0
				send_alert(@athlete, "Passing score alert for ", @fbpassing)
			elsif current_user.stat_alert? and params[:football_passing][:td].to_i == 0
				send_alert(@athlete, "Passing stat alert for ", @fbpassing)
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error updating stats for " + @athlete.full_name			
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
