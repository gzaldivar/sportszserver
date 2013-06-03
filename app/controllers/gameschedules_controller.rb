class GameschedulesController < ApplicationController
	before_filter	:authenticate_user!,  only: [:destroy, :new, :edit, :update, :create]
  before_filter :get_sport
  before_filter :get_schedule,        only: [:show, :edit, :update, :destroy]
  before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
    controller.team_manager?(@gameschedule, @team)
  end
  
  def new
    @gameschedule = Gameschedule.new    
  end
  
  def create
    begin
      schedule = @team.gameschedules.build(params[:gameschedule])
      schedule.starttime = DateTime.civil(schedule.gamedate.year, schedule.gamedate.month, 
                                          schedule.gamedate.day, 
                                          params[:gameschedule][:"starttime(4i)"].to_i,
                                          params[:gameschedule][:"starttime(5i)"].to_i)

      schedule.save!

      respond_to do |format|
        format.html { redirect_to [@sport, @team, schedule] }
        format.xml
        format.json { render json: { schedule: schedule, request: sport_team_gameschedule_url(@sport, @team, schedule) } }
        format.js
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error creating game schedule " + schedule.message }
        format.json { render status: 404, json: { error: e.message, request: sport_team_gameschedule_url(@sport, @team, @gameschedule) } }
      end
    end

  end

  def show
    @gamelogs = @gameschedule.gamelogs.all.sort_by{ |t| [t.period, t.time] }
    @gamelog = @gameschedule.gamelogs.build
    if @sport.name == "Football"
      @stats = AthleteFootballStatsTotal.new
      @stats.passing_totals(@gameschedule)
      @ath_totals = @gameschedule.football_stats
      @stats.rushing_totals(@gameschedule)
      @stats.receiving_totals(@gameschedule)
      @stats.defense_totals(@gameschedule)
      @stats.specialteams_totals(@gameschedule)
      @gameschedule.firstdowns = 0
      @gameschedule.football_stats.each do |f|
        if !f.football_passings.nil?
          @gameschedule.firstdowns = @gameschedule.firstdowns + f.football_passings.firstdowns
        end
      end
      @gameschedule.football_stats.each do |f|
        if !f.football_rushings.nil?
          @gameschedule.firstdowns = @gameschedule.firstdowns + f.football_rushings.firstdowns
        end
      end
    end
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
  end
  
  def update
    begin
      datetime = DateTime.iso8601(params[:gameschedule][:gamedate])
      puts datetime
      @gameschedule.starttime = DateTime.civil(datetime.year, datetime.month, datetime.day, params[:gameschedule][:"starttime(4i)"].to_i,
                                               params[:gameschedule][:"starttime(5i)"].to_i)
      puts @gameschedule.starttime
      @gameschedule.update_attributes!(params[:gameschedule])
      respond_to do |format|
          format.html { redirect_to [@sport, @team, @gameschedule] }
          format.json { render json: { schedule: @gameschedule, request: sport_team_gameschedule_url(@sport, @team, @gameschedule) } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error updating game schedule " + e.message }
        format.json { render status: 404, json: { error: e.message, request: sport_team_gameschedule_url(@sport, @team, @gameschedule) } }
      end
    end
  end
  
  def index
    @gameschedules = []
    @team.gameschedules.asc(:gamedate).each_with_index do |s, cnt|
      @gameschedules[cnt] = s
      @gameschedules[cnt].firstdowns = 0
      s.football_stats.each do |f|
        if !f.football_passings.nil?
          @gameschedules[cnt].firstdowns = @gameschedules[cnt].firstdowns + f.football_passings.firstdowns
        end
      end
      s.football_stats.each do |f|
        if !f.football_rushings.nil?
          @gameschedules[cnt].firstdowns = @gameschedules[cnt].firstdowns + f.football_rushings.firstdowns
        end
      end
    end
    
    respond_to do |format|
      format.html
      format.xml
      format.json 
      format.js
    end    
  end
  
  def destroy
    begin
      @gameschedule.destroy
      respond_to do |format|
        format.html { redirect_to sport_team_gameschedules_path(@sport, @team), notice: "Schedule deleted!" }
        format.json { render json: { message: "Success", request: [@sport, @team] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error deleting schedule" }
        format.json { render status: 404, json: { error: e.message, request: [@sport, @team] } }
      end
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
