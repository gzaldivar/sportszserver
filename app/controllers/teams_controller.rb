class TeamsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy, :index, :show]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_sport
  before_filter :get_team,				only: [:edit, :update, :show, :destroy]

	def new
		@team = Team.new
	end

	def create
		begin
			@team = @sport.teams.create!(params[:team])
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Added #{@team.title} #{@team.mascot}!" }
				format.json { render json: { team: @team, request: sport_team_url(@sport, @team) } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error adding team" }
				format.json { render json: { error: e.message, request: sport_team_url(@sport, @team) } }
			end
		end
	end

	def edit
	end

	def update
		begin
			@team.update_attributes!(params[:team])
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Team updated" }
				format.json { render json: { team: @team, request: sport_team_url(@sport, @team) } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error updating team" }
				format.json  { render json: { error: e.message, request: sport_team_url(@sport, @team) } }
			end
		end
	end

	def index
		@teams = @sport.teams.all.entries
	end

	def show
		respond_to do |format|
			format.html
			format.json
		end
	end

	def destroy
		destroy_team(@team.id.to_s)
		@team.destroy
		redirect_to @sport, notice: "Team delete sucessful!"
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def get_team
			@team = @sport.teams.find(params[:id])
		end

		def destroy_team(team)
			@sport.photos.where(teamid: team).each do |p|
				p.teamid = nil
				p.save
			end
			@sport.videoclips.where(teamid: team).each do |v|
				v.teamid = nil
				v.save
			end
		end
end
