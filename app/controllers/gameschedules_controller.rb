class GameschedulesController < ApplicationController
	before_filter	:authenticate_user! #,   only: [:destroy, :new, :edit, :update, :create]
  before_filter :get_sport
  before_filter :get_schedule,        only: [:show, :edit, :update, :destroy, :updatelogo]
  before_filter only: [:destroy, :update, :create, :edit, :new, :createlogo, :updatelogo] do |controller| 
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
        format.json { render json: { schedule: schedule } }
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

      if @gameschedule.opponent_team_id?
        @opposingsport = Sport.find(@gameschedule.opponent_sport_id)
        @opposingteam = @opposingsport.teams.find(@gameschedule.opponent_team_id)
      end

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
        @stats = @gameschedule.basketball_stats
        totals = StatTotal.new(@sport, @gameschedule)
        
        @gameschedule.homescore = totals.basketball_home_totals
        @gameschedule.homefouls = totals.fouls
      elsif @sport.name == "Soccer"
        @stats = @gameschedule.soccers

        @soccerhomesog = 0
        @soccerhomeck = 0
        @soccerhomesaves = 0
        @gameschedule.homescore = 0

        @stats.each do |s|
          @soccerhomesog += s.shotstaken
          @soccerhomeck += s.cornerkick
          @soccerhomesaves += s.goalssaved
        end

        totals = StatTotal.new(@sport, @gameschedule)
        @gameschedule.homescore = totals.soccer_home_score
        
        puts "Display homescore"
        puts @gameschedule.homescore

        athletes = @players
        @players = []
        @goalies = []
        athletes.each do |a|
          if is_soccer_goalie?(a.position) and hasSoccerPlayerStats?(@stats)
            @goalies << a
            @players << a
          elsif is_soccer_goalie?(a.position)
            @goalies << a
         else
            @players << a
          end
        end
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

    @stats = @gameschedule.soccers

    @soccerhomesog = 0
    @soccerhomeck = 0
    @soccerhomesaves = 0

    @stats.each do |s|
      @soccerhomesog += s.shotstaken
      @soccerhomeck += s.cornerkick
      @soccerhomesaves += s.goalssaved
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

        if @sport.sportname == "Football"
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
        elsif @sport.name == "Basketball"
          totals = StatTotal.new(@sport, @gameschedules[cnt])          
          @gameschedules[cnt].homescore = totals.basketball_home_totals
          @gameschedules[cnt].homefouls = totals.fouls
        elsif @sport.name == "Soccer" 
          totals = StatTotal.new(@sport, @gameschedules[cnt])
          @gameschedules[cnt].homescore = totals.soccer_home_score
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
    @thesport = params[:sport]
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
  
  def createlogo
    begin    
      path = CGI.unescape(params[:filepath]).split('/')
      @gameschedule = @team.gameschedules.find(path[4])    
      path = params[:filepath].split('/')
      imagepath = CGI.unescape(path[2])

      queue = @sport.photo_queues.new(modelid: @gameschedule.id, modelname: "gameschedulelogo", filename: params[:filename], 
                                      filetype: params[:filetype], filepath: imagepath)
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end

    rescue Exception => e
      puts e.message
    end
  end

  def updatelogo
    begin
      queue = @sport.photo_queues.new(modelid: @gameschedule.id, modelname: "gameschedulelogo", filename: params[:filename], filetype: params[:filetype], 
                                      filepath: params[:filepath])
        if queue.save!
            Resque.enqueue(PhotoProcessor, queue.id)
        end

        respond_to do |format|
            format.json { render json: { success: "success", gameschedule: @gameschedule } }
        end
      rescue Exception => e
        respond_to do |format|
            format.json { render status: 404, json: { error: e.message } }
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
