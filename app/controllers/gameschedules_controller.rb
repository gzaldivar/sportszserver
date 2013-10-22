class GameschedulesController < ApplicationController
	before_filter	:authenticate_user! #,   only: [:destroy, :new, :edit, :update, :create]
  before_filter :get_sport
  before_filter :get_schedule,        only: [:show, :edit, :update, :destroy]
  before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
    controller.team_manager?(@gameschedule, @team)
  end
  
  def new
    @gameschedule = Gameschedule.new

    if params[:opponent]
      @opposingsport = Sport.find(params[:opponent].to_s)
      @opposingteam = @opposingsport.teams.find(params[:opposingteam])
    end
  end

  def periods
  end

  def defineperiods
    begin
      @sport.periods = params[:periods]
      @sport.save!
      redirect_to new_sport_team_gameschedule_path(@sport, @team)
    rescue Exception => e
      redirect_to @sport, alert: "Error defining basketball periods - " + e.message
    end
  end
  
  def create
    begin
      schedule = @team.gameschedules.build(params[:gameschedule])
      schedule.starttime = DateTime.civil(schedule.gamedate.year, schedule.gamedate.month, 
                                          schedule.gamedate.day, 
                                          params[:gameschedule][:"starttime(4i)"].to_i,
                                          params[:gameschedule][:"starttime(5i)"].to_i)
      schedule.livegametime = DateTime.civil(schedule.gamedate.year, schedule.gamedate.month, 
                                          schedule.gamedate.day, 
                                          params[:gameschedule][:"livegametime(4i)"].to_i,
                                          params[:gameschedule][:"livegametime(5i)"].to_i)

      schedule.save!

      respond_to do |format|
        format.html { redirect_to [@sport, @team, schedule] }
        format.xml
        format.json { render json: { schedule: schedule } }
        format.js
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error creating game schedule " + schedule.message }
        format.json { render status: 404, json: { error: e.message } }
      end
    end

  end

  def show
    begin
      @players = @sport.athletes.where(team_id: @team.id.to_s).asc(:number)

      if @sport.name == "Football"
        @gamelogs = @gameschedule.gamelogs.all.sort_by{ |t| [t.period, t.time] }
        @gamelog = @gameschedule.gamelogs.build
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
      elsif @sport.name == "Basketball"
        @athletes = @sport.athletes.where(team_id: @gameschedule.team_id.to_s).asc(:number)
        @stats = @gameschedule.basketball_stats
      end
 
      respond_to do |format|
        format.html
        format.json
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error: " + e.message }
        format.json { render status: 404, json: { error: e.message } }
      end
    end
  end
  
  def edit
    if params[:opponent]
      @opposingsport = Sport.find(params[:opponent].to_s)
      @opposingteam = @opposingsport.teams.find(params[:opposingteam])
    elsif !@gameschedule.opponent_sport_id.nil?
      @opposingsport = Sport.find(@gameschedule.opponent_sport_id)
      @opposingteam = @opposingsport.teams.find(@gameschedule.opponent_team_id)
    end
  end
  
  def update
    begin
      datetime = DateTime.iso8601(params[:gameschedule][:gamedate])
      @gameschedule.starttime = DateTime.civil(datetime.year, datetime.month, datetime.day, params[:gameschedule][:"starttime(4i)"].to_i,
                                               params[:gameschedule][:"starttime(5i)"].to_i)
      @gameschedule.livegametime = DateTime.civil(datetime.year, datetime.month, datetime.day, params[:gameschedule][:"livegametime(4i)"].to_i,
                                                  params[:gameschedule][:"livegametime(5i)"].to_i)
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
    begin
      @gameschedules = []
      @team.gameschedules.asc(:gamedate).each_with_index do |s, cnt|
        @gameschedules[cnt] = s
        @gameschedules[cnt].firstdowns = 0

        if @sport.sportname == "Football"
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
        
      end
      
      respond_to do |format|
        format.html
        format.json 
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: e.message }
        format.json { render status: 404, json: { error: e.message } }
      end
    end  
  end

  def findsport
    @sports = find_a_sport(@sport.name)
    if params[:gameschedule_id]
      @gameschedule = @team.gameschedules.find(params[:gameschedule_id].to_s)
    else
      @gameschedule = nil
    end
  end

  def findteam
    @opposingsport = Sport.find(params[:opponent])
    @opposingteams = @opposingsport.teams

    if params[:gameschedule_id]
      @gameschedule = @team.gameschedules.find(params[:gameschedule_id].to_s)
    else
      @gameschedule = nil
    end
  end
  
  def destroy
    begin
      @gameschedule.blogs = nil
      @gameschedule.photos = nil
      @gameschedule.videoclips = nil
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
