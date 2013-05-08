class BasketballStatsController < ApplicationController
	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		controller.team_manager?(@athlete, nil)
	end

	def new		
	end

	def create		
	end

	def show
	end

	def edit
	end

	def update
	end

	def index
	end

	def destroy
	end

	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def get_correct_stat
			@stat = @athlete.basketball_stats.find(params[:id])
		end

end
