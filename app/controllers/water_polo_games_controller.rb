class WaterPoloGamesController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport
  	before_filter	:get_game, only: [:show, :update, :changeperiod, :substitute_player, :addsubstitute_player, :deletesub]
	before_filter only: [:update, :show, :changeperiod, :addsubstitute_player] do |controller| 
		controller.SiteOwner?(@gameschedule.team_id)
	end

	def index
		
	end

	def update
		
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
			@team = @sport.teams.find(params[:team_id])
			@gameschedule = @team.gameschedules.find(params[:gameschedule_id])
		end

		def get_game
			@water_polo_game = @gameschedule.water_polo_game
		end
end
