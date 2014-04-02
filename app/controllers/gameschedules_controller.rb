class GameschedulesController < ApplicationController
  include FootballStatistics
  include BasketballStatistics

	before_filter	:authenticate_user!,   only: [:destroy, :new, :edit, :update, :create]
  before_filter :get_sport
  before_filter :get_schedule,        only: [:show, :edit, :update, :destroy, :updatelogo, :passinggamestats, :allfootballgamestats,
                                              :rushinggamestats, :receivinggamestats, :defensegamestats, :kickergamestats, :returnergamestats, 
                                              :footballboxscore,:footballscoreboard, :footballteamgametotals, :addfootballqb,
                                              :footballdefensestats, :footballspecialteamstats, :addfootballrb, :addfootballrec, :addfootballdef,
                                              :addfootballpk, :addfootballret, :addfootballkicker, :addfootballpunter, :footballform, 
                                              :basketballteamscorestats, :basketballteamotherstats, :basketballform, :soccerform]
  before_filter only: [:destroy, :update, :create, :edit, :new, :createlogo, :updatelogo] do |controller| 
    controller.SiteOwner?(@team.id)
  end
#  before_filter only: [:passinggamestats, :allfootballgamestats, :rushinggamestats, :receivinggamestats, :defensegamestats, 
#                       :kickergamestats, :returnergamestats, :footballteamgametotals, :addfootballqb, :footballdefensestats, 
#                       :footballspecialteamstats, :addfootballrb, :addfootballrec, :addfootballdef, :addfootballpk, :addfootballret, 
#                       :addfootballkicker, :addfootballpunter, :footballform, :basketballteamscorestats, 
#                       :basketballteamotherstats,] do |check|
#    check.packageEnabled?(current_site)
#  end
  
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
      datetime = DateTime.iso8601(params[:gameschedule][:gamedate])

      if params[:starthour]
        if params[:ampm] == "PM" and params[:starthour].to_i != 12
          params[:starthour] = (params[:starthour].to_i + 12).to_s
        end
        schedule.starttime = datetime.change({:hour => params[:starthour].to_i , :min => params[:startminutes].to_i , :sec => 0 })
      else
        schedule.starttime = DateTime.civil(datetime.year, datetime.month, datetime.day, params[:gameschedule][:"starttime(4i)"].to_i,
                                            params[:gameschedule][:"starttime(5i)"].to_i)
      end

#      schedule.livegametime = DateTime.civil(schedule.gamedate.year, schedule.gamedate.month, schedule.gamedate.day, 
#                              params[:gameschedule][:"livegametime(4i)"].to_i,params[:gameschedule][:"livegametime(5i)"].to_i)

      if params[:gameminutes].nil?
        schedule.current_game_time = "00:00"
      else
        schedule.current_game_time = params[:gameminutes].to_s + ":" + params[:gameseconds].to_s
      end
      
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

        if @gameschedule.useopponentstats
#          @visitorhomescore = footballhomescore(@opposingsport, )
        end
      end

      if @sport.name == "Football"
#        @gamelogs = @gameschedule.gamelogs.all.sort_by{ |t| [t.period, t.time] }
        @gamelogs = @gameschedule.gamelogs.asc(:period).desc(:time)

        @footballhomescore = footballhomescore(@sport, @gameschedule)
        @footballtotalyards = footballtotalyards(@sport, @gameschedule)
        @rushingtotalyards = FootballStatistics.rushingyardtotals
        @passingtotalyards = FootballStatistics.passingyardtotals
        @turnovers = FootballStatistics.turnovers

      elsif @sport.name == "Basketball"

        basketballstats = Basketballstats.new(@sport, @gameschedule)
        @stats = basketballstats.stats
        @totals = basketballstats.stattotals

      elsif @sport.name == "Soccer"
        @stats = @gameschedule.soccers
        @totals = Soccer.new(athlete_id: nil, gameschedule_id: @gameschedule.id)

        @stats.each do |s|
          @totals.goals += s.goals
          @totals.shotstaken += s.shotstaken
          @totals.assists += s.assists
          @totals.steals += s.steals
          @totals.cornerkick += s.cornerkick
          @totals.goalsagainst += s.goalsagainst
          @totals.goalssaved += s.goalssaved
          @totals.shutouts += s.shutouts
          @totals.minutesplayed += s.minutesplayed
        end

        totals = StatTotal.new(@sport, @gameschedule)

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
      if params[:starthour]
        if params[:ampm] == "PM" and params[:starthour].to_i != 12
          hour = (params[:starthour].to_i + 12)
        else
          hour = params[:starthour].to_i
        end
  #       time = Time.zone.local(datetime.year, datetime.month, datetime.day, hour, params[:startminutes].to_i)
        @gameschedule.starttime = datetime.change({:hour => hour , :min => params[:startminutes].to_i , :sec => 0 })
      elsif params[:gameschedule][:"starttime(4i)"] and params[:gameschedule][:"starttime(5i)"]
        @gameschedule.starttime = DateTime.civil(datetime.year, datetime.month, datetime.day, params[:gameschedule][:"starttime(4i)"].to_i,
                                                params[:gameschedule][:"starttime(5i)"].to_i)
      end
      
#      @gameschedule.livegametime = DateTime.civil(datetime.year, datetime.month, datetime.day, params[:gameschedule][:"livegametime(4i)"].to_i,
#                                                  params[:gameschedule][:"livegametime(5i)"].to_i)

      if params[:gameminutes]
        @gameschedule.current_game_time = addzerototime(params[:gameminutes].to_s) + ":" + addzerototime(params[:gameseconds].to_s)
      end

      final = @gameschedule.final

      @gameschedule.update_attributes!(params[:gameschedule])

      event = Event.find_by(gameschedule_id: @gameschedule.id)

      if (event)
        event.start_time = @gameschedule.starttime - 30.minutes
        event.end_time = event.start_time + 4.hours
        event.save!
      end

#      if final
#        createNewsItem(@gameschedule)
#      end

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
        elsif @sport.name == "Basketball"
          totals = StatTotal.new(@sport, @gameschedules[cnt])          
        elsif @sport.name == "Soccer" 
          totals = StatTotal.new(@sport, @gameschedules[cnt])
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
        format.html { redirect_to sport_path(@sport), notice: "Game deleted!" }
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

  def passinggamestats
    passstats = Passingstats.new(@sport, @gameschedule)
    @passingstats = passstats.stats
    @passingtotals = passstats.passingtotals

    respond_to do |format|
      format.js
      format.json
    end
  end

  def rushinggamestats
    rushingstats = Rushingstats.new(@sport, @gameschedule)
    @rushingstats = rushingstats.stats
    @rushingtotals = rushingstats.rushingtotals

    respond_to do |format|
      format.js
      format.json
    end
  end

  def receivinggamestats
    receivingstats = Receivingstats.new(@sport, @gameschedule)
    @receivingstats = receivingstats.stats
    @receivingtotals = receivingstats.receivingtotals

    respond_to do |format|
      format.js
      format.json
    end
  end

  def defensegamestats
    defense = Defensestats.new(@sport, @gameschedule)
    @defensivestats = defense.stats
    @defensivetotals = defense.defensetotals

    respond_to do |format|
      format.js
      format.json
    end
  end

  def kickergamestats
    placekicker = Placekickerstats.new(@sport, @gameschedule)
    @placekickerstats = placekicker.stats
    @placekickertotals = placekicker.placekickertotals

    punterstats = Punterstats.new(@sport, @gameschedule)
    @punterstats = punterstats.stats
    @puntertotals = punterstats.puntertotals

    respond_to do |format|
      format.js
      format.json
    end
  end

  def returnergamestats
    returnerstats = Returnerstats.new(@sport, @gameschedule)
    @returnerstats = returnerstats.stats
    @returnertotals = returnerstats.returnertotals

    respond_to do |format|
      format.js
      format.json
    end
  end

  def footballboxscore
    if @gameschedule.opponent_team_id?
      @opposingsport = Sport.find(@gameschedule.opponent_sport_id)
      @opposingteam = @opposingsport.teams.find(@gameschedule.opponent_team_id)
    end
  end

  def footballscoreboard
  end

  def footballteamgametotals
      @footballhomescore = footballhomescore(@sport, @gameschedule)
      @footballtotalyards = footballtotalyards(@sport, @gameschedule)
      @rushingtotalyards = FootballStatistics.rushingyardtotals
      @passingtotalyards = FootballStatistics.passingyardtotals
      @turnovers = FootballStatistics.turnovers

      respond_to do |format|
          format.js
          format.json
      end
  end

  def allfootballgamestats
    passstats = Passingstats.new(@sport, @gameschedule)
    @passingstats = passstats.stats
    @passingtotals = passstats.passingtotals

    rushingstats = Rushingstats.new(@sport, @gameschedule)
    @rushingstats = rushingstats.stats
    @rushingtotals = rushingstats.rushingtotals

    @firstdowns = passstats.gamefirstdowns + rushingstats.gamefirstdowns

    receivingstats = Receivingstats.new(@sport, @gameschedule)
    @receivingstats = receivingstats.stats
    @receivingtotals = receivingstats.receivingtotals
  end

  def footballoffenselive
    passstats = Passingstats.new(@sport, @gameschedule)
    @passingstats = passstats.stats
    @passingtotals = passstats.passingtotals

    rushingstats = Rushingstats.new(@sport, @gameschedule)
    @rushingstats = rushingstats.stats
    @rushingtotals = rushingstats.rushingtotals

    @firstdowns = passstats.gamefirstdowns + rushingstats.gamefirstdowns

    receivingstats = Receivingstats.new(@sport, @gameschedule)
    @receivingstats = receivingstats.stats
    @receivingtotals = receivingstats.receivingtotals
  end

  def footballdefensestats
    defense = Defensestats.new(@sport, @gameschedule)
    @defensivestats = defense.stats
    @defensivetotals = defense.defensetotals
  end

  def footballspecialteamstats
    placekicker = Placekickerstats.new(@sport, @gameschedule)
    @placekickerstats = placekicker.stats
    @placekickertotals = placekicker.placekickertotals

    returnerstats = Returnerstats.new(@sport, @gameschedule)
    @returnerstats = returnerstats.stats
    @returnertotals = returnerstats.returnertotals

    kickoffstats = Kickerstats.new(@sport, @gameschedule)
    @kickoffstats = kickoffstats.stats
    @kickofftotals = kickoffstats.kickertotals

    punterstats = Punterstats.new(@sport, @gameschedule)
    @punterstats = punterstats.stats
    @puntertotals = punterstats.puntertotals
  end

  def addfootballqb
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballrb
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballrec
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballdef
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballpk
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballret
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballkicker
    @athlete = Athlete.find(params[:player_id])
  end

  def addfootballpunter
    @athlete = Athlete.find(params[:player_id])
  end

  def footballform    
  end

  def basketballform
    render 'gameschedules/basketball/basketballform'
  end

  def soccerform
    @soccerhomesog = 0
    @soccerhomeck = 0
    @soccerhomesaves = 0

    @stats = @gameschedule.soccers

    @stats.each do |s|
      @soccerhomesog += s.shotstaken
      @soccerhomeck += s.cornerkick
      @soccerhomesaves += s.goalssaved
    end
   render 'gameschedules/soccer/soccerform'
  end

  def basketballteamscorestats   
    basketballstats = Basketballstats.new(@sport, @gameschedule)
    @stats = basketballstats.stats
    @totals = basketballstats.stattotals
 end

 def basketballteamotherstats
    basketballstats = Basketballstats.new(@sport, @gameschedule)
    @stats = basketballstats.stats
    @totals = basketballstats.stattotals
 end
  
private
  
    def get_sport
      @sport = Sport.find(params[:sport_id])
      @team = @sport.teams.find(params[:team_id])
    end

    def get_schedule
         @gameschedule = @team.gameschedules.find(params[:id])
    end

    def footballgamestats
      
    end

    def addzerototime(time)
      if time.to_i >= 0 and time.to_i <=9
        time = "0" + time
      else
        time
      end
    end

    def createNewsItem(game)
      vsscore = (game.opponentq1 + game.opponentq2 + game.opponentq3 + game.opponentq4)
      result = footballhomescore(@sport, game) > vsscore ? "W" : footballhomescore(@sport, game) == vsscore ? "T" : "L"

      newsitem = @sport.newsfeeds.new(news: @team.mascot + " " + footballhomescore(@sport, game).to_s + " " + game.opponent_mascot + " " + vsscore.to_s, 
                                      title: "Final - " + @team.mascot + " vs " + game.opponent_mascot + " " + result + " " + 
                                              footballhomescore(@sport, game).to_s + "-" + vsscore.to_s, team_id: @team.id,
                                      gameschedule_id: game.id)

      newsitem.save!
    end
    
end
