class AlertsController < ApplicationController
	before_filter :authenticate_user!,	only: [:index, :destroy, :clearall]
	before_filter :get_athlete

	def index
		if params[:alerttype] == "Bio"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :athlete.ne => "", :athlete.exists => true).desc(:created_at).entries
			@list = "Bio"
		elsif params[:alerttype] == "Blog"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :blog.ne => "", :blog.exists => true).desc(:created_at).entries
			@list = "Blog"
		elsif params[:alerttype] == "Media"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :photo.ne => "", :photo.exists => true, :videoclip.ne => "", 
											:videoclip.exists => true).desc(:created_at).entries
			@list = "Media"
		elsif params[:alerttype] == "Stats"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :footall_stat.ne => "", :football_stat.exists => true,
											:stat_football.ne => "", :stat_football.exists => true).desc(:created_at).entries
			@list = "Stats"
		else				
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s).desc(:created_at).entries
			@list = "All"
		end

	  	respond_to do |format|
	  		format.html
	  		format.json
	  	end
	end

	def destroy
		@athlete.alerts.find(params[:id]).destroy

	  	respond_to do |format|
	  		format.html { redirect_to sport_athlete_alerts_path(@sport, @athlete) }
	  		format.json
	  	end
		
	end

	def clearall
		if params[:stats] == "stats"
			@athlete.alerts.where(:football_stat.ne => "", :football_stat.exists => true).destroy
		elsif params[:photo] == "photo"
			@athlete.alerts.where(:photo.ne => "", :photo.exists => true).destroy
		elsif params[:video] == "video"
			@athlete.alerts.where(:videoclip.ne => "", :videoclip.exists => true).destroy
		elsif params[:bio] == "bio"
			@athlete.alerts.where(:athlete.ne => "", :athlete.exists => true).destroy
		elsif params[:blog] == "blog"
			@athlete.alerts.where(:blog.ne => "", :blog.exists => true).destroy
		else
			@athlete.alerts.all.destroy
		end

		respond_to do |format|
			format.html { redirect_to sport_athlete_alerts_path(@sport, @athlete) }
			format.json
		end
	end

	private

		def get_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = @sport.athletes.find(params[:athlete_id])
		end

end
