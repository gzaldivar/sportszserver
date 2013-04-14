class GamelogsController < ApplicationController
    before_filter	:authenticate_user!,  only: [:destroy, :create]
    before_filter :correct_gamelog
    before_filter only: [:destroy, :create] do |controller| 
      controller.team_manager?(@gameschedule)
    end

  	def create
      if @gamelog = @gameschedule.gamelogs.create!(params[:gamelog])
        respond_to do |format|
          format.html { redirect_to [@sport, @team, @gameschedule], success: "Game log entry created!" }
          format.json
        end
      else
        redirect_to :back, alert: "Error creating game log"
      end 		
  	end

  	def destroy
  		@gameschedule.gamelogs.find(params[:id]).destroy
      redirect_to :back, success: "Game log entry deleted!"
  	end

  	private

  		def correct_gamelog
  			@sport = Sport.find(params[:sport_id])
        @team = @sport.teams.find(params[:team_id])
        @gameschedule = @team.gameschedules.find(params[:gameschedule_id])
  		end
end
