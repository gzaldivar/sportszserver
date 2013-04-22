class AlertsController < ApplicationController
	before_filter :authenticate_user!,	only: [:index, :destroy]
	before_filter :get_athlete, only: [:index, :destroy]

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

	private

		def get_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = @sport.athletes.find(params[:athlete_id])
		end

end
