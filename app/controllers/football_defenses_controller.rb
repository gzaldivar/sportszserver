class FootballDefensesController < ApplicationController
	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :new]
	before_filter	:site_owner?,	        only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete_stat, only: [:new, :playbyplay, :create, :show, :edit, :update, :destroy]
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]

	def new
		@defense = FootballDefense.new
	end

	def playbyplay
		@defense = FootballDefense.new
	end

	def create
		if @defense = @stat.create_football_defenses(params[:football_defense])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @defense], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end
		else
			puts 'got here'
			redirect_to :back, error: "Error creating football defense stats"
		end
	end

	def show
	end

	def edit		
	end

	def update
		if @defense.update_attributes(params[:football_defense])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @defense], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end
		else
			redirect_to :back, error: "Error updating stats for " + @athlete.full_name
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
		
end
