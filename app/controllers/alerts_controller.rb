class AlertsController < ApplicationController
	before_filter :authenticate_user!,	only: [:index, :destroy, :clearall]
	before_filter :get_athlete

	def index
		if params[:alerttype] == "Blog"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :blog.ne => "", :blog.exists => true).desc(:created_at).entries
			@list = "Blog"
		elsif params[:alerttype] == "Photo"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :photo.ne => "", :photo.exists => true).desc(:created_at).entries
			@list = "Photo"
		elsif params[:alerttype] == "Video"
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :videoclip.ne => "", 
													  :videoclip.exists => true).desc(:created_at).entries
			@list = "Video"
		elsif params[:alerttype] == "Stats"
			if @sport.name == "Football"
				@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :footall_stat.ne => "", 
												:stat_football.ne => "", :stat_football.exists => true).desc(:created_at).entries
			elsif @sport.name == "Basketball"
				@alerts = @athlete.alerts.where(user_id: current_user.id.to_s, :basketball_stat.ne => "", 
												:basketball_stat.exists => true).desc(:created_at).entries
			end
			@list = "Stats"
		elsif params[:alerttype] == "Bio"
			if @sport.name == "Football"
				@alerts = @athlete.alerts.where(:athlete.ne => "", :photo.ne => "", :photo.exists => false, :videoclip.ne => "", :videoclip.exists => false, 
					:blog.ne => "", :blog.exists => false, :stat_football.ne => "", :stat_football.exists => false, :athlete.exists => true).desc(:created_at)
			elsif @sport.name == "Basketball"
				@alerts = @athlete.alerts.where(:athlete.ne => "", :photo.ne => "", :photo.exists => false, :videoclip.ne => "", :videoclip.exists => false, 
					:blog.ne => "", :blog.exists => false, :basketball_stat.ne => "", :basketball_stat.exists => false, :athlete.exists => true).desc(:created_at)
			end
			@list = "Bio"
		elsif				
			@alerts = @athlete.alerts.where(user_id: current_user.id.to_s).desc(:created_at).entries
			@list = "All"
		end

	  	respond_to do |format|
	  		format.html
	  		format.json 
	  	end
	end

	def destroy
		begin
			alert = @athlete.alerts.find(params[:id])
			alert.destroy

		  	respond_to do |format|
		  		format.html { redirect_to sport_athlete_alerts_path(@sport, @athlete) }
		  		format.json { render json: { success: "success", request: sport_athlete_alerts_url(@sport, @athlete) } }
		  	end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
		
	end

	def clearall
		begin
			if params[:alerttype] == "Stats"

				if @sport.name == "Football"
					@athlete.alerts.where(:football_stat.ne => "", :football_stat.exists => true).destroy
				elsif @sport.name == "Basketball"
					@athlete.alerts.where(:basketball_stat.ne => "", :basketball_stat.exists => true).destroy
				end

			elsif params[:alerttype] == "Photo"
				@athlete.alerts.where(:photo.ne => "", :photo.exists => true).destroy
			elsif params[:alerttype] == "Video"
				@athlete.alerts.where(:videoclip.ne => "", :videoclip.exists => true).destroy
			elsif params[:alerttype] == "Bio"
				if @sport.name == "Football"
					@athlete.alerts.where(:athlete.ne => "", :photo.ne => "", :photo.exists => false, :videoclip.ne => "", :videoclip.exists => false, 
						:blog.ne => "", :blog.exists => false, :football_stat.ne => "", :football_stat.exists => false, :athlete.exists => true).destroy
				elsif @sport.name == "Basketball"
					@athlete.alerts.where(:athlete.ne => "", :photo.ne => "", :photo.exists => false, :videoclip.ne => "", :videoclip.exists => false, 
						:blog.ne => "", :blog.exists => false, :basketball_stat.ne => "", :basketball_stat.exists => false, :athlete.exists => true).destroy
				end
			elsif params[:alerttype] == "Blog"
				@athlete.alerts.where(:blog.ne => "", :blog.exists => true).destroy
			else
				@athlete.alerts.all.destroy
			end

			respond_to do |format|
				format.html { redirect_to sport_athlete_alerts_path(@sport, @athlete) }
				format.json { render json: { success: "success", request: sport_athlete_alerts_url(@sport, @athlete) } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	private

		def get_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = @sport.athletes.find(params[:athlete_id])
		end

end
