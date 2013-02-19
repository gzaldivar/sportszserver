class GameschedulesController < ApplicationController
	before_filter	:authenticate_user!,  only: [:destroy, :new, :edit, :update, :create]
  before_filter :site_owner?,          only: [:destroy, :new, :edit, :update, :create]
  before_filter :get_sport
  
  def new
    @gameschedule = Gameschedule.new    
  end
  
  def create
    schedule = @team.gameschedules.build(params[:gameschedule])
#    schedule.gamedate = Date.civil(params[:gameschedule][:"gamedate(1i)"].to_i,
#                                   params[:gameschedule][:"gamedate(2i)"].to_i,
#                                   params[:gameschedule][:"gamedate(3i)"].to_i)
    schedule.starttime = DateTime.civil(schedule.gamedate.year, schedule.gamedate.month, 
                                        schedule.gamedate.day, 
                                        params[:gameschedule][:"starttime(4i)"].to_i,
                                        params[:gameschedule][:"starttime(5i)"].to_i)

    if schedule.save

      respond_to do |format|
        format.html { redirect_to  sport_team_gameschedules_path }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, error: "Error creating game schedule"
    end

 end
  
  def edit
    @gameschedule = @team.gameschedules.find(params[:id])
  end
  
  def update
    schedule = @team.gameschedules.find(params[:id])
#    schedule.gamedate = Date.strptime(params[:gameschedule][:gamedate].to_s, '%m/%d/%Y').to_s
#    schedule.gamedate = Date.civil(params[:gameschedule][:"gamedate(1i)"].to_i,
#                                   params[:gameschedule][:"gamedate(2i)"].to_i,
#                                   params[:gameschedule][:"gamedate(3i)"].to_i)
    schedule.starttime = DateTime.civil(schedule.gamedate.year, schedule.gamedate.month, 
                                        schedule.gamedate.day, 
                                        params[:gameschedule][:"starttime(4i)"].to_i,
                                        params[:gameschedule][:"starttime(5i)"].to_i)
    if schedule.update_attributes(params[:gameschedule])
     respond_to do |format|
        format.html { redirect_to  sport_team_gameschedules_path }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, error: "Error updating game schedule"
    end
  end
  
  def index
    @gameschedules = []
    @team.gameschedules.asc(:gamedate).each_with_index do |s, cnt|
      @gameschedules[cnt] = s
    end
    
    respond_to do |format|
      format.html
      format.xml
      format.json 
      format.js
    end    
  end
  
  def destroy
    if Gameschedule.find(params[:id]).destroy
      redirect_to :back, notice: "Schedule deleted!"
    else
      redirect_to :back, error: "Error deleting schedule"
    end
  end
  
  private
  
    def get_sport
      @sport = Sport.find(params[:sport_id])
      @team = @sport.teams.find(params[:team_id])
    end
    
end
