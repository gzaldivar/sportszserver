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
			end
			@rushing.save!

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
end
