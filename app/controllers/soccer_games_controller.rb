class SoccerGamesController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport
  	before_filter	:get_game, only: [:show, :update]
	before_filter only: [:update, :show] do |controller| 
		controller.SiteOwner?(@gameschedule.team_id)
	end

	def index
		@soccer_game = @gameschedule.soccer_game
		@players = @sport.athletes.where(team_id: @team.id)
		
		if @gameschedule.soccer_game.visiting_team
			@visiting_team = VisitingTeam.find(@gameschedule.soccer_game.visiting_team_id)
		end
	end

	def update
		begin
			@soccer_game.update_attributes!(params[:soccer_game])

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: 'Update Succesful!' }
				format.json { render status: 200, json: { soccer_game: @soccer_game } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
			@team = @sport.teams.find(params[:team_id])
			@gameschedule = @team.gameschedules.find(params[:gameschedule_id])
		end

		def get_game
			@soccer_game = @gameschedule.soccer_game
		end

end
