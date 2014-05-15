class AlertsController < ApplicationController
	before_filter :authenticate_user!,	only: [:index, :destroy, :clearall]
	before_filter :get_athlete
	before_filter do |check|
		check.packageEnabled?(current_site)
	end

	def index
		if params[:alerttype] == "Blog"
			@alerts = @athlete.alerts.or({ teamusers: current_user.id.to_s }, { users: current_user.id.to_s }).and(:blog.ne => "", 
											:blog.exists => true).desc(:created_at).entries
			@list = "Blog"
		elsif params[:alerttype] == "Photo"
			@alerts = @athlete.alerts.or({ teamusers: current_user.id.to_s }, { users: current_user.id.to_s }).and(:photo.ne => "", 
											:photo.exists => true).desc(:created_at).entries
			@list = "Photo"
		elsif params[:alerttype] == "Video"
			@alerts = @athlete.alerts.or({ teamusers: current_user.id.to_s }, { users: current_user.id.to_s }).and(:videoclip.ne => "", 
											:videoclip.exists => true).desc(:created_at).entries
			@list = "Video"
		elsif params[:alerttype].to_s == "Bio"
			@alerts = @athlete.alerts.or({ teamusers: current_user.id.to_s }, { users: current_user.id.to_s }).desc(:created_at)
			@list = "Bio"
		else				
			@alerts = @athlete.alerts.or({ teamusers: current_user.id.to_s }, { users: current_user.id.to_s }).desc(:created_at).entries
			@list = "All"
		end

	  	respond_to do |format|
	  		format.html
	  		format.json 
	  	end
	end

	def clearuser
		begin
			@alert = Alert.find(params[:alert_id])
			@alert.users.delete(params[:user_id])

			if @alert.teamusers.empty? and @alert.users.empty?
				@alert.destroy
			end
			
			redirect_to :back, notice: "Alert cleared"
		rescue Exception => e
			redirect_to :back, alert: e.message
		end
	end

	def clearteamuser
		begin
			@alert = Alert.find(params[:alert_id])
			@alert.teamusers.delete(params[:user_id])

			if @alert.teamusers.empty? and @alert.users.empty?
				@alert.destroy
			end

			redirect_to :back, notice: "Alert cleared"		
		rescue Exception => e
			redirect_to :back, alert: e.message
		end
	end

	def destroy
		begin
			alert = @athlete.alerts.find(params[:id])
			alert.destroy

		  	respond_to do |format|
		  		format.html { redirect_to :back, notice: "Alert Deleted!" }
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
			if params[:alerttype] == "Photo"
				@athlete.alerts.where(:photo.ne => "", :photo.exists => true).destroy
			elsif params[:alerttype] == "Video"
				@athlete.alerts.where(:videoclip.ne => "", :videoclip.exists => true).destroy
			elsif params[:alerttype] == "Bio"
				@athlete.alerts.where(:athlete.ne => "", :photo.ne => "", :photo.exists => false, :videoclip.ne => "", :videoclip.exists => false, 
						:blog.ne => "", :blog.exists => false, :athlete.exists => true).destroy
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
