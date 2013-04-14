class TeamsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy, :index, :show]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_sport

	def new
		@team = Team.new
	end

	def create
		if @team = @sport.teams.create!(params[:team])
			redirect_to @sport, notice: "Added #{@team.title} #{@team.mascot}!"
		else
			redirect_to @sport, alert: "Error adding team"
		end
	end

	def edit
		@team = @sport.teams.find(params[:id])
	end

	def update
		team = @sport.teams.find(params[:id])
		if team.update_attributes(params[:team])
			redirect_to @sport, notice: "Team updated"
		else
			redirect_to @sport, alert: "Error updating team"
		end
	end

	def index
		@teams = @sport.teams.all.entries
	end

	def show
		@team = @sport.teams.find(params[:id])
	end

	def destroy
		@sport.teams.find(params[:id]).destroy
		redirect_to @sport, notice: "Team delete sucessful!"
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

end
