class SponsorsController < ApplicationController
	before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy, :index, :show]
	before_filter :site_owner?,			only: [:new, :create, :edit, :update, :destroy, :index, :show]
  	before_filter :get_sport
  	before_filter :get_sponsor,		only: [:edit, :show, :destroy]

	def new
		@sponsor = Sponsor.new
	end

	def create
		begin 
			@sponsor = @sport.sponsors.create!(params[:sponsor])
			if !params[:team_id].nil? and !params[:team_id].blank?
				@sponsor.team_id = params[:team_id]
				@sponsor.save!
			end
			redirect_to [@sport, @sponsor], notice: "Added #{@sponsor.name}!"
		rescue Exception => e
			redirect_to :back, alert: "Error adding Sponsor " + e.message
		end
	end

	def edit
	end

	def update
		begin
			sponsor = @sport.sponsors.find(params[:id])
			sponsor.update_attributes!(params[:sponsor])
			redirect_to [@sport, sponsor], notice: "Sponsor updated"
		rescue Exception => e
			redirect_to [@sport, sponsor], alert: "Error updating Sponsor" + e.message
		end
	end

	def index
		@sponsors = @sport.sponsors.all.entries
	end

	def show
	end

	def destroy
		@sponsor.destroy
		redirect_to :back, notice: "Sponsor delete sucessful!"
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def get_sponsor
			@sponsor = @sport.sponsors.find(params[:id])
		end
end
