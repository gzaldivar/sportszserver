class FootballReturnersController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit]
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :editkoreturn, :editpuntreturn, :update, :destroy]

  	def newkoreturn
		@returner = FootballReturner.new
	end

	def newpuntreturn
		@returner = FootballReturner.new
	end

	def create
		begin
			@returner = @stat.create_football_returners(params[:football_returner])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @returner], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error creating football returner stats "	+ e.message
		end
	end

	def show
	end

	def editpuntreturn
	end

	def editkoreturn
	end

	def update
		begin
			@returner.update_attributes!(params[:football_returner])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @returner], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end		
		rescue Exception => e
			redirect_to :back, alert: "Error updating stats for " + @athlete.full_name + " " + e.message		
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
	end
