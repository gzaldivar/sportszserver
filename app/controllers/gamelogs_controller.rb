class GamelogsController < ApplicationController
    before_filter	:authenticate_user! #,  only: [:destroy, :create, :show, :update]
    before_filter :get_gameschedule
    before_filter :correct_gamelog, only: [:destroy, :edit, :update, :show]
    before_filter only: [:destroy, :create, :update] do |controller| 
      controller.team_manager?(@gameschedule, @team)
    end

    def new
      @players = @sport.athletes.where(team_id: @team.id.to_s)
      @gamelog = @gameschedule.gamelogs.new()
    end

  	def create
      begin
        @gamelog = @gameschedule.gamelogs.create!(params[:gamelog])
          respond_to do |format|
            format.html { redirect_to [@sport, @team, @gameschedule], success: "Game log entry created!" }
            format.json { render json: { gamelog: [@sport, @team, @gameschedule, @gamelog] } }
          end
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to :back, alert: "Error creating game log " + e.message }
          format.json { render json: { error: e.message } }
        end
      end 		
  	end

    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    def gamelogs
      @gamelogs = @gameschedule.gamelogs.all.sort_by{ |t| [t.period, t.time] }
    end

    def edit
      @players = @sport.athletes.where(team_id: @team.id.to_s)
    end

    def update
      begin
        @gamelog = @gameschedule.gamelogs.find(params[:id])
        @gamelog.update_attributes!(params[:gamelog])
        
        respond_to do |format|
          format.html { redirect_to [@sport, @team, @gameschedule, @gamelog], notice: "Game log update sucessful!" }
          format.json { render json: { gamelog: [@sport, @team, @gameschedule, @gamelog] } }
        end
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to :back, alert: "Error - " + e.message }
          format.json { render json: { error: e.message } }
        end
      end
    end

  	def destroy
      begin
  		  @gamelog.destroy
        respond_to do |format|
          format.html { redirect_to :back, success: "Game log entry deleted!" }
          format.json { render json: { success: "sucess" } }
        end
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to :back, alert: "Error deleting Game Log Entry " + e.message }
          format.json { render status: 404, json: { error: e.message } }
        end
      end
  	end

  	private

      def get_gameschedule
        @sport = Sport.find(params[:sport_id])
        @team = @sport.teams.find(params[:team_id])
        @gameschedule = @team.gameschedules.find(params[:gameschedule_id])
      end
        
  		def correct_gamelog
        @gamelog = @gameschedule.gamelogs.find(params[:id])
  		end
end
