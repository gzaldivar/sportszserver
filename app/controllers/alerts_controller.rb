class AlertsController < ApplicationController
	before_filter :authenticate_user!,	only: [:index, :destroy, :clearall]
	before_filter :get_athlete

	def index
		@alerts = @athlete.alerts.where(user_id: current_user.id.to_s).entries
	  	respond_to do |format|
	  		format.html
	  		format.json
	  	end
	end

	def destroy
		@athlete.alerts.find(params[:id]).destroy
		redirect_to sport_athlete_alerts_path(@sport, @athlete)
	end

	def clearall
		@athlete.alerts.each do |a|
			if a.user_id == current_user.id
				a.destroy
			end
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
