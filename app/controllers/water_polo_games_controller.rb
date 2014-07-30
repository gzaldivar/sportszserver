class WaterPoloGamesController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport
  	before_filter	:get_game, only: [:show, :update, :changeperiod, :substitute_player, :addsubstitute_player, :deletesub]
	before_filter only: [:update, :show, :changeperiod, :addsubstitute_player] do |controller| 
		controller.SiteOwner?(@gameschedule.team_id)
	end

	def index
		
	end

	def show
		
	end

	def update
		begin
			@water_polo_game.update_attributes!(params[:soccer_game])

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_water_polo_games_path(@sport, @team, @gameschedule, @water_polo_game), notice: 'Update Succesful!' }
				format.json { render status: 200, json: { water_polo_game: @water_polo_game } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
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
