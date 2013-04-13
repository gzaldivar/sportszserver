class FootballPassingsController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete_stat, only: [:new, :playbyplay, :create, :show, :edit, :update, :destroy]
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]

	def new
		@fbpassing = FootballPassing.new
	end

	def playbyplay
		@fbpassing = FootballPassing.new
	end

	def create
		if @fbpassing = @stat.create_football_passings(params[:football_passing])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end
		else
			redirect_to :back, alert: "Error creating football passing stats"
		end
	end

	def show
	end

	def edit		
	end

	def update
		if @fbpassing.update_attributes(params[:football_passing])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @fbpassing], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end
		else
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
		
end
