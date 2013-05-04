class FootballKickersController < ApplicationController
	before_filter	[:authenticate_user!], [:destroy, :update, :create, :edit, :newkicker, :newpunter, :newkickoff,
											:editkicker, :editpunter, :editkickoff]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :editkicker, :editpunter, :editkickoff, :update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :newkicker, :newpunter, :newkickoff,:editkicker, :editpunter, :editkickoff] do |controller| 
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
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error creating football specialteams stats"	+ e.message		
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

	def update
		begin
			@kicker.update_attributes(params[:football_kicker])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @kicker], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error updating stats for " + @athlete.full_name + " " + e.message
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
end
