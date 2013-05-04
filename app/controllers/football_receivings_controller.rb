class FootballReceivingsController < ApplicationController
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete_stat, only: [:new, :playbyplay, :create, :show, :edit, :update, :destroy]
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]

  	def new
		@receiving = FootballReceiving.new
	end

	def create
		begin
			@receiving = @stat.create_football_receivings(params[:football_receiving])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @receiving], notice: 'Stat created for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error creating football receiving stats"			
		end
	end

	def show
	end

	def edit		
	end

	def update
		begin
			@receiving.update_attributes!(params[:football_receiving])
			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @stat, @receiving], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json 
		     end			
		rescue Exception => e
			redirect_to :back, alert: "Error updating stats for " + @athlete.full_name			
		end
	end

	def destroy
		@receiving.destroy
		redirect_to receiving_sport_athlete_football_stats_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
			@stat = @athlete.football_stats.find(params[:football_stat_id])
		end

		def correct_stat
			@receiving = @stat.football_receivings
		end
end
