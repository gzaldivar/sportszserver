class FootballDefensesController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?], only: [:destroy, :update, :create, :edit, :new, :add, :adddefense]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy, :add, :adddefense]
	before_filter only: [:destroy, :update, :create, :edit, :new, :add, :adddefense] do |controller| 
	    controller.team_manager?(@athlete, @stat.gameschedule.team)
	end

	def new
		@defense = FootballDefense.new
	end

	def create
		begin
			@defense = @stat.create_football_defenses(params[:football_defense])
			if current_user.score_alert? and (params[:football_defense][:int_td].to_i > 0 or params[:football_defense][:safety].to_i > 0)
				send_alert("Defensive score alert for ")
			elsif current_user.stat_alert?
				send_alert("Defensive stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @defense], notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { defense: @defense, 
		        			  request: sport_athlete_football_stat_football_defense_url(@sport, @athlete, @stat, @defense) } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football defense stats"	}
		        format.json { render json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_defense_url(@sport, @athlete, @stat, @defense) } }
		     end			
		end
	end

	def show
	end

	def edit		
	end

	def add
	end

	def adddefense
		begin
			@defense.tackles = @defense.tackles + params[:tackles].to_i
			@defense.int_yards = @defense.int_yards + params[:int_yards].to_i
			@defense.fumbles_recovered = @defense.fumbles_recovered + params[:fumbles_recovered].to_i
			@defense.assists = @defense.assists + params[:assists].to_i

			if params[:sack].to_i > 0
				@defense.sacks = @defense.sacks + 1
			end
			if params[:pass_defended].to_i > 0
				@defense.pass_defended = @defense.pass_defended + 1
			end
			if params[:int].to_i > 0
				@defense.interceptions = @defense.interceptions + 1
			end
			if params[:fumbles_recovered].to_i > 0
				@defense.fumbles_recovered = @defense.fumbles_recovered + 1
			end
			if params[:int_yards].to_i > @defense.int_long
				@defense.int_long = params[:int_yards]
			end

			if params[:int_td].to_i > 0
				@defense.int_td = @defense.int_td + 1

				if params[:int].to_i > 0
					gamelog = @defense.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], 
																			   logentry: @athlete.logname + " interception return", score: "TD")
				else
					gamelog = @defense.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																			   logentry: @athlete.logname + " fumble return", score: "TD")
				end

				gamelog.save!
				if params[:quarter]
					@gameschedule = Gameschedule.find(@defense.football_stat.gameschedule)
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

			if params[:safety].to_i > 0
				@defense.safety = @defense.safety + 1
				gamelog = @defense.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																		   logentry: @athlete.logname + " safety", score: "2P")

				gamelog.save!
				if params[:quarter]
					@gameschedule = Gameschedule.find(@defense.football_stat.gameschedule)
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

			@defense.save!

			if current_user.score_alert? and (params[:int_td].to_i > 0 or params[:safety].to_i > 0)
				send_alert("Defensive score alert for ")
			elsif current_user.stat_alert?
				send_alert("Defensive stat alert for ")
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @defense], notice: 'Defensive stat added for ' + @athlete.full_name }
		        format.json { render json: { defense: @defense, 
		        			  request: sport_athlete_football_stat_football_defense_url(@sport, @athlete, @stat, @defense) } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error: " + e.message }
			    format.json { render json: { error: e.message, 
		        			  request: sport_athlete_football_stat_football_defense_url(@sport, @athlete, @stat, @defense) } }
		     end
		end		
	end

	def update
		begin
			@defense.update_attributes!(params[:football_defense])
			if current_user.score_alert? and (params[:football_defense][:int_td].to_i > 0 or params[:football_defense][:safety].to_i > 0)
				send_alert("Defensive score alert for ")
			elsif current_user.stat_alert?
				send_alert("Defensive stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @defense], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json { render json: { defense: @defense, 
		        			  request: sport_athlete_football_stat_football_defense_url(@sport, @athlete, @stat, @defense) } }
		     end			
		rescue Exception => e
			respond_to do |format|
			format.html { redirect_to :back, alert: "Error updating stats for " + e.message	}
		    format.json { render json: { error: e.message, 
		        		  request: sport_athlete_football_stat_football_defense_url(@sport, @athlete, @stat, @defense) } }
		     end			
		end
	end

	def destroy
		@defense.destroy
		redirect_to defense_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@defense = @stat.football_defenses
		end

		def send_alert(message)	
	        Athlete.find(@stat.athlete).fans.each do |user|
	            alert = @stat.athlete.alerts.create!(sport: @sport, user: user, athlete: @stat.athlete, message: message + @stat.gameschedule.game_name, 
	                								 football_stat: @stat.id, stat_football: "Defense")
	        end
		end
		
end
