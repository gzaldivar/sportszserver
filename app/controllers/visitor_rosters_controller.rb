class VisitorRostersController < ApplicationController
	before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
	before_filter :get_sport
	before_filter :get_roster,	only: [:edit, :update, :show, :destroy]
	before_filter only: [:edit, :update, :destroy] do |controller|
		SiteAdmin?(@sport)
	end

	def new
		@visitor_roster = @visiting_team.visitor_rosters.new
	end

	def create
		begin
			visitor_roster = @visiting_team.visitor_rosters.create!(params[:visitor_roster])

			respond_to do |format|
				format.html { redirect_to [@sport, @visiting_team, visitor_roster ]}
				format.json { render status: 200, json: { visitor_roster: visitor_roster } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to [@sport, @visiting_team], notice: "Error creating visiting team player." }
				format.json { render status: 404, json: { visitor_roster: visitor_roster } }
			end
		end
	end

	def edit		
	end

	def update
		begin
			@visitor_roster.update_attributes!(params[:visitor_roster])

			respond_to do |format|
				format.html { redirect_to [@sport, @visiting_team, @visitor_roster] }
				format.json { render status: 200, json: { visitor_roster: @visitor_roster } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to [@sport, @visiting_team], notice: "Error updating visiting team player " + e.message }
				format.json { render status: 404, json: { visitor_roster: e.message } }
			end
		end
	end

	def show		
	end

	def index
		@visitor_rosters = @visiting_team.visitor_rosters.all.asc(:number)
	end

	def destroy
		
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
			@visiting_team = @sport.visiting_teams.find(params[:visiting_team_id])
		end

		def get_roster
			@visitor_roster = @visiting_team.visitor_rosters.find(params[:id])
		end
end
