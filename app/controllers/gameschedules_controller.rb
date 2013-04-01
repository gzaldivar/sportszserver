class GameschedulesController < ApplicationController
	before_filter	:authenticate_user!,  only: [:destroy, :new, :edit, :update, :create]
  before_filter :site_owner?,          only: [:destroy, :new, :edit, :update, :create]
  before_filter :get_sport
  before_filter :get_schedule,        only: [:show, :edit, :update, :destroy]
  
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
        format.html { redirect_to [@sport, @team, schedule] }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, error: "Error creating game schedule"
    end

  end

  def show
    @gamelogs = @gameschedule.gamelogs.all.sort_by{ |t| [t.period, t.time] }
    @gamelog = @gameschedule.gamelogs.build
    if @sport.name == "Football"
      @stats = AthleteFootballStatsTotal.new
      @stats.passing_totals(@gameschedule)
      @stats.rushing_totals(@gameschedule)
      @stats.receiving_totals(@gameschedule)
      @stats.defense_totals(@gameschedule)
      @stats.specialteams_totals(@gameschedule)
    end
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
  end
  
  def update
#    schedule = @team.gameschedules.find(params[:id])
#    schedule.gamedate = Date.strptime(params[:gameschedule][:gamedate].to_s, '%m/%d/%Y').to_s
#    schedule.gamedate = Date.civil(params[:gameschedule][:"gamedate(1i)"].to_i,
#                                   params[:gameschedule][:"gamedate(2i)"].to_i,
#                                   params[:gameschedule][:"gamedate(3i)"].to_i)
    @gameschedule.starttime = DateTime.civil(@gameschedule.gamedate.year, @gameschedule.gamedate.month, 
                                        @gameschedule.gamedate.day, 
                                        params[:gameschedule][:"starttime(4i)"].to_i,
                                        params[:gameschedule][:"starttime(5i)"].to_i)
    if @gameschedule.update_attributes(params[:gameschedule])
     respond_to do |format|
        format.html { redirect_to [@sport, @team, @gameschedule] }
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
    if @gameschedule.destroy
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

    def get_schedule
         @gameschedule = @team.gameschedules.find(params[:id])
    end
    
end
