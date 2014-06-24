class SoccerStatsController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_stat, only: [:edit, :update, :destroy, :show]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		controller.SiteOwner?(@athlete.team_id)
	end

	def index
	end

	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def get_stat
			@stats = @athlete.soccers.find(params[:id])
		end

end
