class LacrossPlayerStatsController < ApplicationController

	before_filter	:authenticate_user!, only: [:destroy]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_lacrossestats, only: [:destroy]
	before_filter 	only: [:destroy] do |controller| 
		controller.SiteAdmin?(@sport)
	end

	def create
		begin
			stat = LacrossPlayerStat.new

			stat.create!(params[:lacross_player_stat])

			respond_to do |format|
				format.json { render status: 200, json: { lacross_player_stat: stat } }
			end
		rescue Exception => e
			respond_to do |format|
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def update
		begin
			@stat.update_attributes!(params[:lacross_player_stat])

			respond_to do |format|
				format.json { render status: 200, json: { lacross_player_stat: @stat } }
			end
		rescue Exception => e
			respond_to do |format|
				format.json { render status: 404, json: { error: e.message } }
			end
		end	
	end

	def destroy
	end

	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = @sport.athletes.find(params[:athlete_id])
		end

		def get_player_stat
			@stat = @athlete.lacross_player_stats.find(params[:id])
		end

end
