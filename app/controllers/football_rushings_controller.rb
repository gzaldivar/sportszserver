class FootballRushingsController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete_stat, only: [:new, :playbyplay, :create, :show, :edit, :update, :destroy]
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]

  	def new
		@rushing = FootballRushing.new
	end

	def playbyplay
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
