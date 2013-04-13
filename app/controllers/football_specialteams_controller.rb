class FootballSpecialteamsController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :editkicker, :editpunter, :editkoreturn, :editpuntreturn, :editkickoff, 
  												   :update, :destroy]

  	def newkoreturn
		@specialteams = FootballSpecialteams.new
	end

	def newkicker
		@specialteams = FootballSpecialteam.new
	end

	def newpunter
		@specialteams = FootballSpecialteam.new
	end

	def newpuntreturn
		@specialteams = FootballSpecialteam.new
	end

	def newkickoff
		@specialteams = FootballSpecialteam.new
	end

	def playbyplay
		@specialteams = FootballSpecialteam.new
	end

	def create
		if @specialteams = @stat.create_football_specialteams(params[:football_specialteam])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @specialteams], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end
		else
			redirect_to :back, alert: "Error creating football specialteams stats"
		end
	end

	def show
	end

	def editkicker
	end

	def editpunter
	end

	def editpuntreturn
	end

	def editkoreturn
	end

	def editkickoff
	end

	def update
		if @specialteams.update_attributes(params[:football_specialteam])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @specialteams], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end
		else
			redirect_to :back, alert: "Error updating stats for " + @athlete.full_name
		end
	end

	def destroy
		@specialteams.destroy
		redirect_to specialteams_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@specialteams = @stat.football_specialteams
		end
end
