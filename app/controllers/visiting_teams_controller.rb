class VisitingTeamsController < ApplicationController
	before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
	before_filter :get_sport
	before_filter :get_team,	only: [:edit, :update, :show, :destroy]
	before_filter only: [:edit, :update, :destroy] do |controller|
		SiteOwner?(@visiting_team.id)
	end

	def new
		@visiting_team = @sport.visiting_teams.new
	end

	def create
		begin
			visiting_team = @sport.visiting_teams.create!(params[:visiting_team])

			respond_to do |format|
				format.html { redirect_to [@sport, visiting_team] }
				format.json { render status: 200, json: { visiting_team: visiting_team } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Error creating visiting team." }
				format.json { render status: 404, json: { visiting_team: visiting_team } }
			end
		end
	end

	def edit
	end

	def show
	end

	def update
		begin
			@visiting_team.update_attributes!(params[:visiting_team])

			respond_to do |format|
				format.html { redirect_to [@sport, @visiting_team], notice: "Updated " + @visiting_team.title + " " + @visiting_team.mascot }
				format.json { render status: 200, json: { visiting_team: @visiting_team } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Error creating visiting team - " + e.message }
				format.json { render status: 404, json: { visiting_team: @visiting_team } }
			end
		end
	end

	def index
		@visiting_teams = @sport.visiting_teams.all

		if @visiting_teams.nil?
			@visiting_teams = []
		end

		respond_to do |format|
			format.html 
			format.json 
		end
	end

	def destroy
		begin
			@visiting_team.destroy

			respond_to do |format|
				format.html { redirect_to @sport, notice: "Visiting Team deleted!" }
				format.json { render status: 200, json: { sucess: "Visiting team deleted!" } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Error deleting visiting team - " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def get_team
			@visiting_team = @sport.visiting_teams.find(params[:id])
		end
end
