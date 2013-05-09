class FootballRushingsController < ApplicationController
	before_filter	[:authenticate_user!],	only: [:destroy, :update, :create, :edit, :new, :add, :addcarry]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy, :add, :addcarry]
	before_filter only: [:destroy, :update, :create, :edit, :new, :add, :addcarry] do |controller| 
	    controller.team_manager?(@athlete, @stat.gameschedule.team)
	end

  	def new
		@rushing = FootballRushing.new
	end

	def create
		begin
			@rushing = @stat.create_football_rushings(params[:football_rushing])
			if current_user.score_alert? and params[:football_rushing][:td].to_i > 0
				send_alert(@athlete, "Rushing score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Rushing stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @rushing], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		    end
		rescue Exception => e
			redirect_to :back, alert: "Error creating football rushing stats " + e.message
		end
	end

	def show
	end

	def add
	end

	def addcarry
		begin
			@rushing.attempts = @rushing.attempts + 1
			@rushing.yards = @rushing.yards + params[:yards].to_i
			@rushing.fumbles = @rushing.fumbles + params[:fumble].to_i
			if params[:yards].to_i > @rushing.longest
				@rushing.longest = params[:yards].to_i
			end
			if params[:td].to_i > 0
				@rushing.td = @rushing.td + params[:td].to_i
				gamelog = @rushing.football_stat.gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], 
												logentry: @athlete.logname + " " +  params[:yards] + " yard run", score: "TD")
				gamelog.save!
				if params[:quarter]
					@gameschedule = Gameschedule.find(@rushing.football_stat.gameschedule)
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
			@rushing.save!

			if current_user.score_alert? and params[:td].to_i > 0
				send_alert(@athlete, "Rushing score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Rushing stat alert for ")
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @rushing], notice: 'Carry added for ' + @athlete.full_name }
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
			@rushing.update_attributes!(params[:football_rushing])
			@rushing = @stat.create_football_rushings(params[:football_rushing])
			if current_user.score_alert? and params[:football_rushing][:td].to_i > 0
				send_alert(@athlete, "Rushing score alert for ")
			elsif current_user.stat_alert?
				send_alert(@athlete, "Rushing stat alert for ")
			end
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @rushing], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end
		rescue Exception => e
			redirect_to :back, alert: "Error updating stats for " + @athlete.full_name + " " + e.message
		end 
	end

	def destroy
		@rushing.destroy
		redirect_to rushing_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@rushing = @stat.football_rushings
		end

		def send_alert(athlete, message)	
	        Athlete.find(athlete).fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + @stat.gameschedule.game_name, 
	                						   football_stat: @stat.id, stat_football: "Rushing")
	        end
		end

end
